# ClickNCart — Microservices Edition

This is your original ClickNCart app (Spring Boot + React + MySQL), rebuilt
from a single monolith into **3 microservices**, plus the basic Kubernetes
manifests to run it as a real (small) cluster. It's meant as a learning
project: everything here is deliberately kept at the *simplest working
version* of each concept, with comments explaining why each decision was
made and what the "next level up" looks like once you're ready for it.

---

## 1. Why split it into 3 services, and why these 3

The original app had 4 controllers: User, Product, OrderDetails, Payment —
all sharing one database and one JAR. That's a monolith: simple to run, but
you can't deploy, scale, or reason about "the checkout flow" independently
from "the product catalog."

| Service | Owns | Port | Why grouped this way |
|---|---|---|---|
| **user-service** | Registration, login, JWT issuing | 8081 | Auth is its own concern — nothing else needs to touch the users table directly |
| **catalog-service** | Products, categories, search | 8082 | Pure read-heavy browsing traffic — very different scaling needs than checkout |
| **order-service** | Cart, Orders, OrderDetail, Payment (Razorpay) | 8083 | Checkout is one transactional flow — kept together rather than split into 4, so you have exactly 3 services as you asked for, without oversplitting for a first attempt |

**What "if you skip this" looks like:** if you leave it as one service, you
can never redeploy the catalog without also risking downtime on checkout;
you can't scale product-browsing pods separately from payment pods even
though they have wildly different load patterns; and one memory leak in any
one feature takes the whole app down. Splitting is what makes each of those
independently true.

## 2. What actually had to change (not just "moved files")

This is the part that's easy to skip and get wrong, so it's worth being
explicit: **splitting a monolith isn't just copying folders — you have to
break the direct object relationships between the pieces that no longer
share a database.**

- `Cart` used to have `@ManyToOne Product product;` — a real JPA foreign
  key, because Cart and Product were in the same database. Now Cart lives
  in order-service's database and Product lives in catalog-service's
  database — **there is no foreign key possible across two different
  databases**. So `Cart` now just stores `productId` (a plain `int`), and
  order-service asks catalog-service over the network, via
  `ProductClient.java`, whenever it needs the actual price.
- Same story for `Cart.user` → `User` and `Orders.user` → `User`: both are
  now plain `userId` integers, taken straight out of the JWT token, instead
  of a live database relationship to user-service's `User` table.
- **Auth had to become stateless.** In the monolith, every request re-loaded
  the full `User` row from the database to check who was logged in.
  catalog-service and order-service don't have a users table at all now, so
  they can't do that. Instead, all 3 services share one `jwt.secret`
  (see `k8s/jwt-secret.yaml`) — user-service is the only one that *issues*
  tokens (at login), but any service can *validate* one and read the
  userId/roles straight out of it, without ever talking to a database.
  This is the standard "shared trust" pattern for a small number of
  services; an API gateway or asymmetric key signing is the natural next
  step once you outgrow it.
- `OrderService.placeOrder()` used to compute the cart total with a plain
  Java field access (`cart.getProduct().getPrice()`). Now it's a real HTTP
  call to `catalog-service` for every cart item. This is the core trade-off
  of microservices: cleaner boundaries, in exchange for needing the network
  between services to actually be up. If catalog-service is down,
  `placeOrder()` will now fail — that's expected, and worth seeing happen
  once, on purpose, so you understand the failure mode you've signed up
  for.

## 3. On the "images not loading" report

Your product image URLs are valid external CDN links (`cdn.dummyjson.com`),
not local files, and the frontend's nginx config has no header that would
block them. That means it's very unlikely to be a Kubernetes/networking
problem — the browser loads those images directly from the CDN, completely
bypassing your cluster. I didn't want to hand you a fix for a problem I
hadn't actually confirmed, so nothing was changed here speculatively.

**When you redeploy this and see it happen again:** open your browser's dev
tools → Network tab, reload the page, and look at the failed image
requests. The status code and error there (404? CORS error? mixed-content
warning? just a blank/broken icon?) will tell us the real cause immediately
— bring that back and we'll fix it properly instead of guessing.

## 4. Repo layout

```
clickncart-microservices/
├── user-service/       Spring Boot - auth & users (port 8081)
├── catalog-service/     Spring Boot - products & catalog (port 8082)
├── order-service/       Spring Boot - cart, orders, payment (port 8083)
├── frontend/             React + nginx, routes /api/* to the 3 services above
├── database/            init.sql - creates userdb/catalogdb/orderdb on one shared MySQL
├── docker-compose.yml    Local testing - run this FIRST, before Kubernetes
└── k8s/                 Kubernetes manifests for the basic cluster deployment
    ├── namespace.yaml
    ├── jwt-secret.yaml   Shared secret all 3 services trust
    ├── mysql/            configmap (init.sql), secret, deployment, service
    ├── user-service/
    ├── catalog-service/
    ├── order-service/
    ├── frontend/
    └── ingress/
```

Every Java file has comments at the point where something changed from the
monolith and why — read those inline, they're the "why" you asked for,
attached directly to the code they explain, rather than repeated here.

## 5. Running it locally first (do this before Kubernetes)

Always prove it works with plain Docker before adding Kubernetes on top —
if something's broken, you want to know it's an app bug, not a cluster
config bug.

```bash
cd clickncart-microservices
docker compose up --build
```

Then visit `http://localhost:3000`. Behind the scenes:
- frontend → `:3000` → nginx → routes `/api/register`,`/api/login` to
  user-service, `/api/products` etc. to catalog-service, `/api/carts`,
  `/api/orders` etc. to order-service
- all 3 backend services → one shared MySQL container, 3 separate databases

If registration/login/browsing/checkout all work here, you're ready for the
cluster.

## 6. Deploying to a Kubernetes cluster (the "basic cluster" step)

This assumes a cluster you can already reach with `kubectl` — a local one
(kind or minikube) is the right place to start before touching EKS again,
since you can iterate for free and fast.

**Build and load the images** (example shown for `kind`; swap the load step
for `minikube image load` or push to ECR if you go back to EKS):

```bash
docker build -t user-service:latest ./user-service
docker build -t catalog-service:latest ./catalog-service
docker build -t order-service:latest ./order-service
docker build -t frontend:latest ./frontend

kind load docker-image user-service:latest catalog-service:latest order-service:latest frontend:latest
```

**Apply the manifests, in this order** (namespace and secrets first, since
everything else refers to them):

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/jwt-secret.yaml
kubectl apply -f k8s/mysql/
kubectl apply -f k8s/user-service/
kubectl apply -f k8s/catalog-service/
kubectl apply -f k8s/order-service/
kubectl apply -f k8s/frontend/
```

**Check everything came up:**
```bash
kubectl get pods -n clickncart
kubectl get svc -n clickncart
```

**See it without an Ingress controller first** (fastest way to check it's
alive):
```bash
kubectl port-forward -n clickncart svc/frontend-service 3000:80
```
Visit `http://localhost:3000`.

**With an Ingress** (once you want it to look like a real routed
deployment): install an ingress controller in your cluster (e.g.
`minikube addons enable ingress`, or the ingress-nginx Helm chart on
kind/EKS), then:
```bash
kubectl apply -f k8s/ingress/ingress.yaml
```

## 7. What's intentionally left simple for now

You said you want to start at the basic cluster level and grow from there —
here's exactly what was kept simple on purpose, and what upgrading it looks
like when you're ready:

- **One shared MySQL pod, 3 databases** instead of 3 separate MySQL pods.
  Real database-per-service isolation would give each service its own
  MySQL Deployment + PVC — a very natural "next" exercise once this basic
  version is working.
- **`emptyDir` storage for MySQL**, not a PersistentVolumeClaim — data is
  lost if the mysql pod restarts. Fine for learning, not for anything real.
- **No CI/CD pipeline included this round** — you already know Jenkins from
  the monolith build; the natural next step is one Jenkinsfile per service
  (or one parameterized one) once this is deploying cleanly by hand.
- **No Helm chart** — plain manifests first, so you can see exactly what
  Kubernetes is doing without a templating layer in between. Helm is a
  good next step once you're deploying this by hand comfortably.
- **No Prometheus/Grafana/ELK yet** — get the 4 services talking reliably
  first; observability is much easier to reason about once you already
  know what "normal" looks like.

Update this project yourself as you go — you know the codebase now, and
each of the "left simple" items above is a good next exercise in exactly
the order you already listed (Helm, then monitoring, then GitOps).
