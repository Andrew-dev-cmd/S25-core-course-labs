{{/*
Expand the name of the chart.
*/}}
{{- define "moscow-time.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a fully qualified app name.
*/}}
{{- define "moscow-time.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "moscow-time.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "moscow-time.labels" -}}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
app.kubernetes.io/name: "{{ include "moscow-time.name" . }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "moscow-time.selectorLabels" -}}
app.kubernetes.io/name: {{ include "moscow-time.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
