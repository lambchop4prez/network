{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "radarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "radarr.fullname" -}}
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

{{- define "radarr.claims.config" -}}
{{- if .Values.persistence.useExistingClaim }}
{{- .Values.persistence.config.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "radarr.fullname" . -}}
{{- printf "%s-%s" $fullname "config" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{- define "radarr.claims.library" -}}
{{- if .Values.persistence.useExistingClaim }}
{{- .Values.persistence.library.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "radarr.fullname" . -}}
{{- printf "%s-%s" $fullname "library" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{- define "radarr.claims.downloads" -}}
{{- if .Values.persistence.useExistingClaim }}
{{- .Values.persistence.downloads.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "radarr.fullname" . -}}
{{- printf "%s-%s" $fullname "downloads" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{- define "radarr.claims.movies" -}}
{{- if .Values.persistence.useExistingClaim }}
{{- .Values.persistence.movies.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "radarr.fullname" . -}}
{{- printf "%s-%s" $fullname "movies" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "radarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "radarr.labels" -}}
helm.sh/chart: {{ include "radarr.chart" . }}
{{ include "radarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "radarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "radarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "radarr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "radarr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
