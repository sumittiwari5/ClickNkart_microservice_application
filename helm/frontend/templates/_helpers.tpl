{{- define "frontend.versionedDeployment" -}}
{{- $root := .root -}}
{{- $version := .version -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-v{{ $version }}
  labels:
    app: frontend
    version: "v{{ $version }}"
  {{- if .retiredAt }}
  annotations:
    retired-at: {{ .retiredAt | quote }}
  {{- end }}
spec:
  replicas: {{ $root.Values.replicaCount }}
  selector:
    matchLabels:
      app: frontend
      version: "v{{ $version }}"
  template:
    metadata:
      labels:
        app: frontend
        version: "v{{ $version }}"
    spec:
      nodeSelector:
        {{- toYaml $root.Values.nodeSelector | nindent 8 }}
      tolerations:
        {{- toYaml $root.Values.tolerations | nindent 8 }}
      containers:
        - name: frontend
          image: "{{ $root.Values.image.repository }}:{{ .imageTag }}"
          ports:
            - containerPort: 80
          resources:
            {{- toYaml $root.Values.resources | nindent 12 }}
          # nginx has no /actuator/health - plain TCP/HTTP check on "/" instead
          readinessProbe:
            httpGet: { path: /, port: 80 }
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet: { path: /, port: 80 }
            initialDelaySeconds: 10
            periodSeconds: 15
{{- end -}}

{{- define "frontend.versionedHPA" -}}
{{- $root := .root -}}
{{- $version := .version -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-v{{ $version }}-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend-v{{ $version }}
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

{{- define "frontend.versionedPDB" -}}
{{- $version := .version -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: frontend-v{{ $version }}-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: frontend
      version: "v{{ $version }}"
{{- end -}}
