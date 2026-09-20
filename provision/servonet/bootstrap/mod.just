
set quiet := true
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']
[private]
default:
    just -l servonet bootstrap

[private]
controller: 
    talosctl config info -o yaml | yq -e '.endpoints[0]'

[doc('Render talosconfig from template')]
[script]
talosconfig:
    just log info "Running stage..." "stage" "$(basename "$0")"
    export TALOSCONFIG="${TALOSCONFIG:-{{ justfile_dir() }}/talosconfig}"
    mkdir -p "$(dirname "${TALOSCONFIG}")"
    if ! just template "{{ source_directory() }}/talosconfig.yaml.j2" "{{ source_directory() }}/../nodes.yaml" > "${TALOSCONFIG}.tmp"; then
        just log fatal "Failed to render talosconfig" "stage" "$(basename "$0")"
    fi
    chmod 600 "${TALOSCONFIG}.tmp"
    mv -f "${TALOSCONFIG}.tmp" "${TALOSCONFIG}"
    just log info "Rendered talosconfig" "stage" "$(basename "$0")" "path" "${TALOSCONFIG}"

[doc('Mint Talos admin client cert against the Machine CA (offline)')]
[script]
mint-admin-cert:
    just log info "Running stage..." "stage" "$(basename "$0")"
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if ! fnox exec -- bash -euo pipefail -c '
        base64 -d <<< "${MACHINE_CA_CRT:?MACHINE_CA_CRT missing from fnox}" > "${1}/ca.crt"
        base64 -d <<< "${MACHINE_CA_KEY:?MACHINE_CA_KEY missing from fnox}" > "${1}/ca.key"
        cd "${1}"
        talosctl gen key --name admin
        talosctl gen csr --key admin.key --ip 127.0.0.1
        talosctl gen crt --ca ca --csr admin.csr --name admin
    ' _ "${tmp}"; then
        just log fatal "Failed to mint admin certificate" "stage" "$(basename "$0")"
    fi
    admin_crt="$(base64 < "${tmp}/admin.crt" | tr -d '\n')"
    admin_key="$(base64 < "${tmp}/admin.key" | tr -d '\n')"
    if [[ "$(uname)" == "Darwin" ]]; then
        security add-generic-password -U -s fnox -a ADMIN_CRT -w "${admin_crt}"
        security add-generic-password -U -s fnox -a ADMIN_KEY -w "${admin_key}"
        just log info "Stored ADMIN_CRT/ADMIN_KEY in keychain" "stage" "$(basename "$0")"
    else
        out="${XDG_CONFIG_HOME:-${HOME}/.config}/servonet"
        mkdir -p "${out}"
        printf '%s' "${admin_crt}" > "${out}/admin.crt.b64"
        printf '%s' "${admin_key}" > "${out}/admin.key.b64"
        chmod 600 "${out}/admin.crt.b64" "${out}/admin.key.b64"
        just log info "Stored admin cert locally" "stage" "$(basename "$0")" "path" "${out}"
    fi

[confirm('Bootstrap cluster? [y|N]')]
[doc('Bootstrap a Talos & Kubernetes cluster end-to-end')]
cluster: talosconfig nodes k8s kubeconfig base resources apps

[private]
[script]
nodes:
    just log info "Running stage..." "stage" "$(basename "$0")"
    for n in $(just servonet nodes); do
        just log info "Apply..." "node" "$n"
        if ! op=$(just servonet apply-config "$n" --insecure 2>&1); then
            if [[ "$op" == *"certificate required"* ]]; then
                just log info "Talos already configured, skipping apply of config" "stage" "$(basename "$0")" "node" "$n"
                continue
            fi
            just log fatal "Failed to apply Talos configuration" "stage" "$(basename "$0")" "node" "$n" "output" "$op"
        fi
    done

[private]
[script]
k8s:
    just log info "Running stage..." "stage" "$(basename "$0")"
    export CONTROLLER="$(just servonet bootstrap controller)"
    until op=$(talosctl -n "${CONTROLLER}" bootstrap 2>&1 || true) && [[ "$op" == *"AlreadyExists"* ]]; do
        just log info "Kubernetes bootstrap in progress. Retrying in 5 seconds..." "stage" "$(basename "$0")"
        sleep 5
    done

[private]
[script]
kubeconfig:
    just log info "Running stage..." "stage" "$(basename "$0")"
    export CONTROLLER="$(just servonet bootstrap controller)"
    if ! talosctl kubeconfig -n "${CONTROLLER}" -f --force-context-name main {{ justfile_dir() }}; then
        just log fatal "Failed to fetch kubeconfig" "stage" "$(basename "$0")"
    fi

[private]
[script]
base: ready
    just log info "Running stage..." "stage" "$(basename "$0")"
    if ! helmfile -f "{{ source_directory() }}/helmfile/crds.yaml" template -q | yq ea -e 'select(.kind == "CustomResourceDefinition")' | kubectl apply --server-side --force-conflicts -f -; then
        just log fatal "Failed to apply base crds" "stage" "$(basename "$0")"
    fi

[doc('Apply resources')]
resources:
    just log info "Apply resources"
    just servonet namespaces
    if ! just template  "{{ source_directory() }}/resources.yaml.j2" | kubectl apply --server-side -f -; then \
        just log fatal "Failed to apply resources"; \
    fi;

[private]
[script]
apps:
    just log info "Running stage..." "stage" "$(basename "$0")"
    if ! helmfile -f "{{ source_directory() }}/helmfile/apps.yaml" sync --hide-notes; then
        just log fatal "Failed to sync helmfile" "stage" "$(basename "$0")"
    fi

[private]
[script]
ready:
    just log info "Running stage..." "stage" "$(basename "$0")"
    if ! kubectl wait nodes --for=condition=Ready=True --all --timeout=10s &>/dev/null; then
        until kubectl wait nodes --for=condition=Ready=False --all --timeout=10s &>/dev/null; do
            just log info "Nodes not available, waiting for nodes to be available. Retrying in 5 seconds..." "stage" "$(basename "$0")"
            sleep 5
        done
    fi
