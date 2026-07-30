# What goes in this folder

Grafana dashboard JSON exports go here, loaded via the ConfigMap
referenced in `monitoring/prometheus/values.yaml` (`clickncart-dashboards`).

**Dashboards worth building for this app, and why each one matters:**

| Dashboard | What it shows | Why it matters for THIS app |
|---|---|---|
| JVM Overview | Heap usage, GC pauses, thread count, per service | Spring Boot's default actuator metrics - catches memory leaks before they cause an OOM kill |
| HTTP Request Metrics | Request rate, latency (p50/p95/p99), error rate, per endpoint | This is what tells you catalog-service's `/api/search-products` is slow, specifically - not just "the app feels slow" |
| Pod/Node Resource Usage | CPU/memory per pod vs its requests/limits | This is what tells you WHEN and WHY HPA scaled, and whether your resource requests in each Helm chart's values.yaml are sized right |
| Database Connections | HikariCP active/idle/pending connections, per service | Directly answers the connection-pool-exhaustion scenario you and I discussed earlier - this dashboard would have shown it happening in real time |
| Blue-Green Deployment Health | Request success rate split by `color` label | Lets you watch a deployment's health in real time DURING the switch, not just before/after |

Build these once Prometheus is actually scraping real data - a dashboard against no data teaches you nothing. Start with JVM Overview and HTTP Request Metrics first; those two alone catch most real problems.
