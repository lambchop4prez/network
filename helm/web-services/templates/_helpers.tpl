{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "web-services.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "web-services.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "web-services.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "web-services.labels" -}}
helm.sh/chart: {{ include "web-services.chart" . }}
{{ include "web-services.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "web-services.selectorLabels" -}}
app.kubernetes.io/name: {{ include "web-services.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Config PV labels
*/}}
{{- define "web-services.configLabels" -}}
bucket: {{ .Values.persistence.config.name }}
{{ include "web-services.selectorLabels" . }}
{{- end }}

{{/*
Library PV labels
*/}}
{{- define "web-services.libraryLabels" -}}
bucket: {{ .Values.persistence.library.name }}
{{ include "web-services.selectorLabels" . }}
{{- end }}

{{/*
Library PV labels
*/}}
{{- define "web-services.downloadsLabels" -}}
bucket: {{ .Values.persistence.downloads.name }}
{{ include "web-services.selectorLabels" . }}
{{- end }}

{{/*
Library PV labels
*/}}
{{- define "web-services.tvLabels" -}}
bucket: {{ .Values.persistence.tv.name }}
{{ include "web-services.selectorLabels" . }}
{{- end }}

{{/*
Library PV labels
*/}}
{{- define "web-services.moviesLabels" -}}
bucket: {{ .Values.persistence.movies.name }}
{{ include "web-services.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "web-services.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "web-services.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
