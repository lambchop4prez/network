#!/usr/bin/env -S just --justfile

set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

ns := "mlops"

[doc('Manually scale the retain worker: 0 = park retain until off hours, 1 = drain the backlog now (e.g. before a break). CronJobs re-apply the schedule nightly/each morning.')]
scale replicas:
    if [[ ! "{{ replicas }}" =~ ^[01]$ ]]; then echo "usage: just hindsight scale <0|1>" >&2; exit 1; fi
    kubectl --namespace {{ ns }} scale statefulset/hindsight-worker --replicas={{ replicas }}
    kubectl --namespace {{ ns }} get statefulset hindsight-worker

[doc('Show worker state and next scheduled scale runs')]
status:
    kubectl --namespace {{ ns }} get statefulset hindsight-worker
    kubectl --namespace {{ ns }} get cronjob hindsight-worker-sleep hindsight-worker-wake
