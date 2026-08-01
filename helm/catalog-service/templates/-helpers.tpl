{{/*
Named template rendering ONE versioned Deployment. Called up to 3 different
"shapes" of times from deployment.yaml: once for liveVersion (always),
once for candidateVersion (only if a release is in progress), and once per
entry in retiredVersions (zero, one, or several). Centralizing the actual
pod spec here means the probes/resources/nodeSelector logic is written
ONCE, not duplicated per version-block in deployment.yaml.

Expects a dict with keys: version, imageTag, retiredAt (empty string if
not retired), plus the root context passed as "root" so this template can
still reach .Values for the shared config (nodeSelector, resources, etc).
*/}}
{{- define "catalog-service.versionedDeployment" -}}
{{- $root := .root -}}
{{- $version := .version -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog-service-v{{ $version }}
  labels:
    app: catalog-service
    version: "v{{ $version }}"
  {{- if .retiredAt }}
  annotations:
    retired-at: {{ .retiredAt | quote }}
  {{- end }}
spec:
  replicas: {{ $root.Values.replicaCount }}
  selector:
    matchLabels:
      app: catalog-service
      version: "v{{ $version }}"
  template:
    metadata:
      labels:
        app: catalog-service
        version: "v{{ $version }}"
    spec:
      nodeSelector:
        {{- toYaml $root.Values.nodeSelector | nindent 8 }}
      tolerations:
        {{- toYaml $root.Values.tolerations | nindent 8 }}
      containers:
        - name: catalog-service
          image: "{{ $root.Values.image.repository }}:{{ .imageTag }}"
          ports:
            - containerPort: 8082
          envFrom:
            - secretRef:
                name: {{ $root.Values.secretName }}
          resources:
            {{- toYaml $root.Values.resources | nindent 12 }}
          startupProbe:
            httpGet:
              path: /actuator/health
              port: 8082
            failureThreshold: 30
            periodSeconds: 5
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: 8082
            initialDelaySeconds: 10
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: 8082
            initialDelaySeconds: 30
            periodSeconds: 15
{{- end -}}

{{/* Same pattern for the per-version HPA - called from hpa.yaml */}}
{{- define "catalog-service.versionedHPA" -}}
{{- $root := .root -}}
{{- $version := .version -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: catalog-service-v{{ $version }}-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: catalog-service-v{{ $version }}
  minReplicas: {{ $root.Values.hpa.minReplicas }}
  maxReplicas: {{ $root.Values.hpa.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $root.Values.hpa.targetCPUUtilizationPercentage }}
{{- end -}}

{{/* Same pattern for the per-version PDB - called from pdb.yaml */}}
{{- define "catalog-service.versionedPDB" -}}
{{- $version := .version -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: catalog-service-v{{ $version }}-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: catalog-service
      version: "v{{ $version }}"
{{- end -}}
