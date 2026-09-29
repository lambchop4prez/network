#!/usr/bin/env -S just --justfile

set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[group('analyze')]
fmt *args:
    # provision/gpc is managed with OpenTofu (see .terraform.lock.hcl)
    tofu fmt {{ args }}

init *args:
    tofu init {{ args }}

[group('analyze')]
validate *args: (init '-backend=false')
    tofu validate {{ args }}
