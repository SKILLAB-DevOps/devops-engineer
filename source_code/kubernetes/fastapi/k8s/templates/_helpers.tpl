{{/* Generate basic labels */}}
{{- define "fastapi.labels" -}}
app.kubernetes.io/name: {{ include "fastapi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Define the name template */}}
{{- define "fastapi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Define the fullname template */}}
{{- define "fastapi.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Create selector labels */}}
{{- define "fastapi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fastapi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
