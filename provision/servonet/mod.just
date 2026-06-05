set quiet := true
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

provision_dir := justfile_dir() + '/provision/servonet'
cluster_dir := justfile_dir() + '/cluster'
default_node := "choose"
default_ext := "raw.xz"

mod bootstrap 'bootstrap'

[doc('List nodes')]
nodes:
    yq -r '.nodes | keys.[]' nodes.yaml

[private]
choose node=default_node:
    echo {{ if node == "choose" { `gum choose $(just servonet nodes)` } else { node } }}

[doc('Generate config')]
config node:    
    yq -r '.nodes["{{node}}"]' nodes.yaml

[doc('Apply namespaces')]
namespaces:
    just log info "Apply namespaces"
    find "{{ cluster_dir }}/apps" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | while IFS= read -r ns; do \
      if ! kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply --server-side -f -; then \
        just log fatal "Failed to apply namespace" "namespace", "$ns"; \
      fi; \
    done

schematic node: 
    just servonet schematic-id "$(yq -r '.nodes["{{ node }}"].schematic' nodes.yaml)"

[doc('Get schematic ID from Talos schematic')]
schematic-id schematic:
    curl -sX POST --data-binary @<(just template "{{ provision_dir }}/schematic/{{ schematic }}.yaml.j2") "https://factory.talos.dev/schematics" | jq -r '.id'

[doc('Download Talos machine image')]
[script]
download version arch schematic ext=default_ext:
    export SCHEMATIC="$(just servonet schematic-id {{ schematic }})"
    gum spin --title "Download Talos {{ version }} {{ schematic }}..." -- \
    curl -sfL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors \
        -o "{{ provision_dir }}/talos-{{ version }}-{{ arch }}-{{ replace_regex(schematic, '^(.{10}).*', '$1') }}.{{ ext }}" \
        "https://factory.talos.dev/image/${SCHEMATIC}/{{ version }}/metal-{{ arch }}.{{ ext }}"
    just log info "Downloaded Talos" version "{{ version }}" arch "{{ arch }}" schematic "{{ schematic }}"

[doc('Download all images')]
download-all version: (download version "arm64" "rpi") (download version "arm64" "turing-rk1") (download version "amd64" "amd-vm" "iso")

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
[script]
render-config node=default_node:
    export NODE=$(just servonet choose {{ node }})
    export IS_CONTROLLER="$(just servonet machine-controller ${NODE})"
    export SCHEMATIC="$(just servonet schematic ${NODE})"
    talosctl machineconfig patch <(just template "{{ provision_dir }}/machineconfig.yaml.j2" "{{ provision_dir }}/nodes.yaml" "--select nodes.${NODE}") 

[private]
machine-controller node:
    yq -r '.nodes["{{ node }}"].controlplane == true' nodes.yaml  
