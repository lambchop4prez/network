set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

provision_dir := justfile_dir() + '/provision/servonet'
cluster_dir := justfile_dir() + '/cluster'

[doc('Generate config')]
config:
    just log info "Generate config"
    talhelper genconfig

[doc('Bootstrap talos')]
talos:
    just log info "Bootstrap talos"
    talhelper gencommand bootstrap | bash

[doc('Config nodes')]
nodes:
    just log info "Apply node config"
    if ! talhelper gencommand apply --extra-flags='--insecure' | bash; then \
      just log fatal "Failed to apply node resources"; \
    fi;

[doc('Bootstrap kubernetes')]
k8s:
    echo 'Bootstrap k8s'

[doc('Apply namespaces')]
namespaces:
    just log info "Apply namepsaces"
    find "{{ cluster_dir }}/apps" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | while IFS= read -r ns; do \
      if ! kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply --server-side -f -; then \
        just log fatal "Failed to apply namespace" "namespace", "$ns"; \
      fi; \
    done

[doc('Apply resources')]
resources:
    just log info "Apply resources"
    if ! just template  "{{ provision_dir }}/resources.yaml.j2" | kubectl apply --server-side -f -; then \
        just log fatal "Failed to apply resources"; \
    fi;

[doc('Bootstrap cluster')]
cluster:
    just log info 'Bootstrap cluster'
    helmfile sync
    sops exec-file "{{ cluster_dir }}/components/sops/secrets.sops.yaml" "kubectl --namespace flux-system apply --server-side --filename {}"

[doc('Download Talos machine image')]
download version arch schematic:
    gum spin --title "Download Talos {{ version }}..." -- \
    curl -sfL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors \
        -o "{{ provision_dir }}/talos-{{ version }}-{{ arch }}-{{ replace_regex(schematic, '^(.{8}).*', '$1') }}.iso" \
        "https://factory.talos.dev/image/{{ schematic }}/{{ version }}/metal-{{ arch }}.iso"
    just log info "Downloaded Talos" version "{{ version }}" arch "{{ arch }}" schematic "{{ schematic }}"


[doc('Get schematic ID from Talos schematic')]
schematic-id schematic:
    curl -sX POST --data-binary @<(just template "{{ provision_dir }}/schematic/{{ schematic }}.yaml.j2") "https://factory.talos.dev/schematics" | jq -r '.id'

[doc('Reboot a node')]
reboot node:
    gum confirm "Reboot {{ node }}?" --default="No" && \
        talosctl -n {{ node }} reboot -m powercycle || exit 0

[doc('Shutdown a node')]
shutdown node *args:
    gum confirm "Shutdown {{ node }}?" --default="No" && \
        talosctl -n {{ node }} shutdown --force {{ args }} | exit 0

[doc('Apply Talos config to node')]
apply-config node *args:
    just servonet render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Render talos config for a node')]
render-config node:
    export IS_CONTROLLER="$(just servonet machine-controller {{ node }})"; \
    talosctl machineconfig patch <(just template "{{ provision_dir }}/machineconfig.yaml.j2") \
        -p @<(just template "{{ provision_dir }}/nodes/{{ node }}.yaml.j2")

[private]
machine-controller node:
    just template "{{ provision_dir }}/nodes/{{ node }}.yaml.j2" | yq -e 'select(.machine) | (.machine.type == "controlplane") // ""'
