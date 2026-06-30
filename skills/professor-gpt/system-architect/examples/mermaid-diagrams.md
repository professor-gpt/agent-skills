# Mermaid Diagram Examples for System Architecture

Copy-paste ready diagrams for common architectural patterns.
Render at: https://mermaid.live

---

## 1. System Context Diagram (C4 Level 1)

```mermaid
C4Context
    title System Context — E-commerce Platform

    Person(customer, "Customer", "Browses and purchases products")
    Person(admin, "Admin", "Manages inventory and orders")

    System(platform, "E-commerce Platform", "Allows customers to browse, purchase, and track orders")

    System_Ext(stripe, "Stripe", "Payment processing")
    System_Ext(sendgrid, "SendGrid", "Transactional email")
    System_Ext(shipengine, "ShipEngine", "Shipping label generation")
    System_Ext(warehouse, "Warehouse WMS", "Inventory and fulfillment")

    Rel(customer, platform, "Uses", "HTTPS")
    Rel(admin, platform, "Manages via", "HTTPS")
    Rel(platform, stripe, "Processes payments", "HTTPS/REST")
    Rel(platform, sendgrid, "Sends emails", "HTTPS/REST")
    Rel(platform, shipengine, "Creates shipments", "HTTPS/REST")
    Rel(platform, warehouse, "Syncs inventory", "Webhook/REST")
```

---

## 2. Container Diagram (C4 Level 2)

```mermaid
C4Container
    title Container Diagram — E-commerce Platform

    Person(customer, "Customer")

    Container_Boundary(platform, "E-commerce Platform") {
        Container(spa, "Web App", "Next.js", "Server-side rendered storefront")
        Container(api, "API Server", "Node.js/Express", "REST API — business logic and data access")
        Container(worker, "Background Worker", "BullMQ/Node.js", "Order processing, email, webhooks")
        ContainerDb(pg, "PostgreSQL", "Database", "Orders, users, products, inventory")
        ContainerDb(redis, "Redis", "Cache + Queue", "Session store, job queue, rate limiting")
        Container(storage, "Object Storage", "S3", "Product images, receipts, exports")
    }

    System_Ext(stripe, "Stripe")
    System_Ext(sendgrid, "SendGrid")

    Rel(customer, spa, "Visits", "HTTPS")
    Rel(spa, api, "API calls", "HTTPS/JSON")
    Rel(api, pg, "Reads/Writes", "TCP/SQL")
    Rel(api, redis, "Cache + enqueue", "TCP")
    Rel(worker, redis, "Dequeue jobs", "TCP")
    Rel(worker, pg, "Updates order state", "TCP/SQL")
    Rel(worker, stripe, "Charge/refund", "HTTPS")
    Rel(worker, sendgrid, "Send email", "HTTPS")
    Rel(api, storage, "Upload/signed URLs", "HTTPS")
```

---

## 3. Sequence Diagram — Checkout Flow

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Frontend
    participant API
    participant Stripe
    participant DB
    participant Queue

    User->>Frontend: Click "Place Order"
    Frontend->>API: POST /orders {cart, paymentMethodId}
    API->>DB: BEGIN TRANSACTION
    API->>DB: Check inventory (SELECT FOR UPDATE)

    alt Inventory available
        API->>DB: Reserve items (UPDATE inventory SET reserved = reserved + qty)
        API->>Stripe: Create PaymentIntent
        Stripe-->>API: {clientSecret, paymentIntentId}
        API->>DB: INSERT order (status=PENDING_PAYMENT, paymentIntentId)
        API->>DB: COMMIT
        API-->>Frontend: {orderId, clientSecret}

        Frontend->>Stripe: Confirm payment (stripe.confirmPayment)
        Stripe-->>Frontend: {status: "succeeded"}
        Frontend->>API: POST /orders/:id/confirm

        API->>Queue: Enqueue("process-order", {orderId})
        API-->>Frontend: {status: "confirmed"}
        Queue-->>API: (async) process fulfillment
    else Out of stock
        API->>DB: ROLLBACK
        API-->>Frontend: 409 {error: "INVENTORY_INSUFFICIENT", items: [...]}
    end
```

---

## 4. State Diagram — Order Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING_PAYMENT: Order created

    PENDING_PAYMENT --> CONFIRMED: Payment succeeded
    PENDING_PAYMENT --> CANCELLED: Payment failed / timeout (30 min)

    CONFIRMED --> PROCESSING: Warehouse picks up
    CONFIRMED --> CANCELLED: Customer cancels (< 30 min)

    PROCESSING --> SHIPPED: Label created + scanned out
    PROCESSING --> FAILED: Fulfillment error

    SHIPPED --> DELIVERED: Carrier confirms delivery
    SHIPPED --> RETURN_REQUESTED: Customer files return

    DELIVERED --> RETURN_REQUESTED: Within return window (30 days)
    DELIVERED --> CLOSED: No action (30 days after delivery)

    RETURN_REQUESTED --> RETURN_IN_TRANSIT: Label scanned
    RETURN_IN_TRANSIT --> REFUNDED: Item received + inspected

    FAILED --> [*]: Manual resolution
    CANCELLED --> [*]
    CLOSED --> [*]
    REFUNDED --> [*]
```

---

## 5. Entity Relationship Diagram

```mermaid
erDiagram
    USER {
        uuid id PK
        string email UK
        string name
        string plan
        timestamp created_at
    }

    ORDER {
        uuid id PK
        uuid user_id FK
        string status
        decimal total_amount
        string currency
        string stripe_payment_intent_id UK
        timestamp placed_at
        timestamp fulfilled_at
    }

    ORDER_ITEM {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        decimal unit_price
    }

    PRODUCT {
        uuid id PK
        string sku UK
        string name
        decimal price
        int inventory_count
        boolean is_active
    }

    ADDRESS {
        uuid id PK
        uuid user_id FK
        string line1
        string city
        string country
        string postal_code
        boolean is_default
    }

    USER ||--o{ ORDER : "places"
    ORDER ||--o{ ORDER_ITEM : "contains"
    PRODUCT ||--o{ ORDER_ITEM : "included in"
    USER ||--o{ ADDRESS : "has"
```

---

## 6. Deployment Diagram (Cloud Infrastructure)

```mermaid
graph TB
    subgraph Internet
        CDN[CloudFront CDN]
        DNS[Route 53]
    end

    subgraph "AWS us-east-1"
        subgraph "Public Subnet"
            ALB[Application Load Balancer]
        end

        subgraph "Private Subnet — App Tier"
            ECS1[ECS Task: Next.js\n×3 instances]
            ECS2[ECS Task: API Server\n×3 instances]
            ECS3[ECS Task: Worker\n×2 instances]
        end

        subgraph "Private Subnet — Data Tier"
            RDS[(RDS PostgreSQL\nMulti-AZ)]
            RDSr[(RDS Read Replica)]
            Redis[(ElastiCache Redis\nCluster Mode)]
        end

        S3[S3 Bucket\nProduct Images]
        ECR[ECR Container Registry]
        SM[Secrets Manager]
    end

    DNS --> CDN
    CDN --> ALB
    ALB --> ECS1
    ALB --> ECS2
    ECS1 --> ECS2
    ECS2 --> RDS
    ECS2 --> RDSr
    ECS2 --> Redis
    ECS3 --> Redis
    ECS3 --> RDS
    ECS2 --> S3
    ECS2 --> SM
    ECS3 --> SM

    classDef aws fill:#FF9900,stroke:#232F3E,color:#000
    classDef data fill:#3F8624,stroke:#232F3E,color:#fff
    classDef compute fill:#8C4FFF,stroke:#232F3E,color:#fff
    class S3,ECR,SM,ALB aws
    class RDS,RDSr,Redis data
    class ECS1,ECS2,ECS3 compute
```

---

## 7. Event-Driven Architecture

```mermaid
graph LR
    subgraph Producers
        API[API Server]
        Worker[Worker]
    end

    subgraph "Event Bus (Kafka)"
        T1[order.placed]
        T2[order.fulfilled]
        T3[payment.captured]
        T4[inventory.updated]
    end

    subgraph Consumers
        EmailSvc[Email Service]
        AnalyticsSvc[Analytics Service]
        InventorySvc[Inventory Service]
        SearchSvc[Search Indexer]
        WebhookSvc[Webhook Dispatcher]
    end

    API -->|publish| T1
    API -->|publish| T3
    Worker -->|publish| T2
    Worker -->|publish| T4

    T1 -->|subscribe| EmailSvc
    T1 -->|subscribe| InventorySvc
    T1 -->|subscribe| WebhookSvc
    T2 -->|subscribe| EmailSvc
    T2 -->|subscribe| WebhookSvc
    T3 -->|subscribe| AnalyticsSvc
    T4 -->|subscribe| SearchSvc
    T4 -->|subscribe| AnalyticsSvc
```
