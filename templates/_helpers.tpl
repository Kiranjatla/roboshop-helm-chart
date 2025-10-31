{{/*
Expand the name of the chart.
*/}}
{{- define "roboshop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "roboshop.fullname" -}}
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
{{- define "roboshop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "roboshop.labels" -}}
helm.sh/chart: {{ include "roboshop.chart" . }}
{{ include "roboshop.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "roboshop.selectorLabels" -}}
app.kubernetes.io/name: {{ include "roboshop.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "roboshop.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "roboshop.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return "true" only if:
  1. externalSecrets.enabled = true
  2. The ExternalSecret CRD exists on the cluster
*/}}
{{- define "externalSecrets.canRender" -}}
{{- $enabled := .Values.externalSecrets.enabled | default false -}}
{{- $crd := lookup "apiextensions.k8s.io/v1" "CustomResourceDefinition" "externalsecrets.external-secrets.io" "" -}}
{{- if and $enabled $crd -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}