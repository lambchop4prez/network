#!/usr/bin/env -S just --justfile

set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[group('analyze')]
[script]
kubeconform:
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    out="$tmpdir/rendered.yaml"
    : > "$out"
    while IFS= read -r kustomization; do
        kind="$(yq '.kind // "Kustomization"' "$kustomization")"
        [[ "$kind" == "Kustomization" ]] || continue
        echo "kustomize build $(dirname "$kustomization")"
        echo '---' >> "$out"
        kustomize build "$(dirname "$kustomization")" >> "$out"
    done < <(find . -name kustomization.yaml | sort)
    kubeconform -strict -ignore-missing-schemas -summary "$out"
