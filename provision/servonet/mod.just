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
