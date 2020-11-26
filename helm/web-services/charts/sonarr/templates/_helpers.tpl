{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sonarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sonarr.fullname" -}}
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

{{- define "sonarr.claims.config" -}}
{{- if .Values.persistence.useExistingClaim }}
{{- .Values.persistence.config.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "sonarr.fullname" . -}}
{{- printf "%s-%s" $fullname "config" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{- define "sonarr.claims.download" -}}
{{- if .Values.persistence.useExistingClaim }}
{{- .Values.persistence.download.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "sonarr.fullname" . -}}
{{- printf "%s-%s" $fullname "download" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{- define "sonarr.claims.tv" -}}
{{- if .Values.persistence.useExistingClaim }}
{{- .Values.persistence.tv.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "sonarr.fullname" . -}}
{{- printf "%s-%s" $fullname "tv" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sonarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sonarr.labels" -}}
helm.sh/chart: {{ include "sonarr.chart" . }}
{{ include "sonarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sonarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sonarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sonarr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sonarr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
