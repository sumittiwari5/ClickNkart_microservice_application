# Logging stack - install order and why

1. **Elasticsearch** (via `elastic/elasticsearch` Helm chart) - stores and indexes the logs
2. **Kibana** (via `elastic/kibana` Helm chart) - the web UI for searching/visualizing what's in Elasticsearch
3. **Fluent Bit** (this folder's values.yaml, via `fluent/fluent-bit` chart) - the shipper: tails every container's stdout/stderr on every node and forwards it to Elasticsearch

Install in that order - Fluent Bit will just retry/queue if Elasticsearch isn't up yet, but there's nothing to look at in Kibana until Elasticsearch exists first.

**What you'll actually search for once this is running:** every log line is tagged with the Kubernetes metadata from the `kubernetes` filter above - so in Kibana you can filter to `kubernetes.labels.app: "order-service" AND kubernetes.labels.color: "green"` to see ONLY the new color's logs during a Blue-Green switch, which is exactly the visibility you want while validating a release.