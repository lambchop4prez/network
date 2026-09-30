#!/usr/bin/env -S just --justfile

set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

mod cluster 'cluster'
mod servonet 'provision/servonet'
mod gpc 'provision/gpc'

[private]
default:
    just -l

[private]
log lvl msg *args:
    gum log --time rfc822 -s --level "{{ lvl }}" "{{ msg }}" {{ args }}

[private]
template file *args:
    fnox exec -- minijinja-cli --env "{{ file }}" {{ args }}

[group('setup')]
setup:
    lefthook install

[group('analyze')]
spellcheck:
    typos --config "{{ justfile_dir() }}/.config/typos.toml"

[group('analyze')]
[parallel]
analyze: spellcheck cluster::kubeconform servonet::bootstrap::helmfile (gpc::fmt '-check') gpc::validate
    just log info "Static analysis complete"
