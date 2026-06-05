
set quiet := true
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']
[private]
default:
    just -l servonet bootstrap

[private]
controller: 
    talosctl config info -o yaml | yq -e '.endpoints[0]'

[confirm('Bootstrap cluster? [y|N]')]
[doc('Bootstrap a Talos & Kubernetes cluster end-to-end')]
cluster: nodes k8s kubeconfig base resources apps

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
