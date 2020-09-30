{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "usenet.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "usenet.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "nzbget.name" -}}
{{- .Values.nzbget.name }}
{{- end }}

{{- define "nzbget.fullname" -}}
{{- if .Values.nzbget.fullnameOverride }}
{{- .Values.nzbget.fullnameOverride | trunc 63 | trimSuffix "-"}}
{{- else }}
{{- printf "%s-%s" .Release.Name .Values.nzbget.name | trunc 63 | trimSuffix "-"}}
{{- end }}
{{- end }}

{{- define "radarr.name" -}}
{{- .Values.radarr.name }}
{{- end }}

{{- define "radarr.fullname" -}}
{{- if .Values.radarr.fullnameOverride }}
{{- .values.radarr.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Values.radarr.name | trunc 63 | trimSuffix "-"}}
{{- end }}
{{- end }}

{{- define "sonarr.name" -}}
{{- .Values.sonarr.name }}
{{- end }}

{{- define "sonarr.fullname" -}}
{{- if .Values.sonarr.fullnameOverride }}
{{- .values.sonarr.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Values.sonarr.name | trunc 63 | trimSuffix "-"}}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "usenet.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "usenet.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
nzbget labels
*/}}
{{- define "nzbget.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nzbget.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}

{{- end }}

{{- define "nzbget.labels" -}}
{{ include "common.labels" . }}
{{ include "nzbget.selectorLabels" . }}
{{- end }}

{{- define "sonarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sonarr.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "sonarr.labels" -}}
{{ include "common.labels" . }}
{{ include "sonarr.selectorLabels" . }}
{{- end }}


{{- define "radarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "radarr.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "radarr.labels" -}}
{{ include "common.labels" . }}
{{ include "radarr.selectorLabels" . }}
{{- end }}

{{- define "usenet.labels" -}}
helm.sh/chart: {{ include "usenet.chart" . }}
{{ include "usenet.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "usenet.selectorLabels" -}}
app.kubernetes.io/name: {{ include "usenet.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "usenet.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "usenet.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
