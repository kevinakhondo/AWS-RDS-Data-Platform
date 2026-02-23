# AWS-RDS-Data-Platform

# Private RDS + AWS Client VPN Data Platform

End‑to‑end data engineering project demonstrating secure database access using AWS networking best practices. The architecture mirrors real enterprise setups: a **private PostgreSQL RDS** accessible only through **AWS Client VPN**, with local ingestion and analytics transformations.

---

#  Architecture

```
Local Laptop (Python, pgAdmin)
        │
        │ AWS Client VPN (certificate auth)
        ▼
AWS VPC (10.0.0.0/16)
   ├── Private Subnet A (RDS)
   ├── Private Subnet B (RDS)
   └── VPN Subnet
        ▼
Amazon RDS PostgreSQL (private)
        ▼
Schemas: raw → staging → marts
```

Key properties:

* RDS **not publicly accessible**
* Access restricted to VPC
* Laptop joins VPC via VPN
* pgAdmin connects securely
* Python ingestion over VPN

---

# 🚀 Project Goals

This project demonstrates:

* Private cloud networking with Terraform
* AWS Client VPN with certificate auth
* Secure database connectivity
* Data ingestion from local environment
* Medallion architecture (raw/staging/marts)
* SQL transformations for analytics

---

# 📁 Repository Structure

```
private-rds-vpn-data-platform/
│
|
│── modules/
│   │   ├── networking/
│   │   ├── rds/
│   │   └── vpn/
│   │
│── environments/
│       └── dev/
│           ├── main.tf
│           ├── variables.tf
│           ├── dev.tfvars
│           ├── outputs.tf
│   
│
├── scripts/
│   └── generate_data.py
│
└── README.md
```

---

# Infrastructure Setup (Terraform)

## 1. Initialize

```
cd terraform/environments/dev
terraform init
```

Fix applied:

* Added missing TLS provider
* Generated VPN certificates in Terraform

---

## 2. Networking

Creates:

* VPC (10.0.0.0/16)
* 2 private subnets (multi‑AZ RDS requirement)
* VPN subnet
* Route tables

Debugging performed:

* Fixed subnet CIDR conflicts
* Ensured 2 AZ coverage for RDS subnet group

---

## 3. RDS (Private PostgreSQL)

Configuration:

* Not publicly accessible
* Subnet group across 2 AZs
* Security group allows VPC CIDR

Debugging performed:

* Fixed subnet group AZ error
* Verified private connectivity via VPN

---

## 4. AWS Client VPN

Configured:

* Certificate authentication
* ACM imported server cert
* Client cert generation via TLS
* VPC route association

Key fix:

```
split_tunnel = true
```

Why:

* Prevents VPN hijacking all internet traffic
* Only VPC routes go via VPN

---

# VPN Certificate Generation

Terraform creates:

* CA cert
* Server cert
* Client cert

Export commands:

```
terraform output -raw client_certificate > client.crt
terraform output -raw client_private_key > client.key
terraform output -raw ca_certificate > ca.crt
```

Debugging performed:

* Fixed missing outputs from module scope
* Corrected TLS resource references

---

#  VPN Connection

Downloaded AWS Client VPN configuration (.ovpn)

Appended certificates:

```
<cert>
CLIENT CERT
</cert>

<key>
CLIENT KEY
</key>
```

Result:

* VPN connected successfully
* Laptop joined VPC network

---

# Database Connection (pgAdmin)

Connection parameters:

* Host: RDS endpoint
* Port: 5432
* User: postgres
* SSL: prefer

Verified:

```
nc -vz <rds-endpoint> 5432
```

---

#  Data Engineering Layer

## Schemas

```
CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA marts;
```

Medallion pattern:

* raw: ingested data
* staging: cleaned joins
* marts: analytics tables

---

# Data Ingestion (Python → VPN → RDS)

Driver install:

```
pip3 install psycopg2-binary
```

Mac fix:

```
python3 scripts/generate_data.py
```

Why:

macOS uses python3 instead of python alias

---

## Synthetic Data Generator

Creates:

* 200 customers
* 1000 transactions

Loads into:

* raw.customers
* raw.transactions

---

# Transformations (SQL)

## Staging

```
CREATE TABLE staging.transactions_clean AS
SELECT t.*, c.country
FROM raw.transactions t
JOIN raw.customers c
  ON t.customer_id = c.customer_id;
```

## Mart

```
CREATE TABLE marts.daily_revenue AS
SELECT
  DATE(created_at) AS date,
  country,
  COUNT(*) tx_count,
  SUM(amount) revenue
FROM staging.transactions_clean
WHERE status = 'SUCCESS'
GROUP BY 1,2;
```

---

# Result

Analytics‑ready table:

* daily revenue by country
* transaction counts
* time series metrics
  
<img width="1680" height="653" alt="image" src="https://github.com/user-attachments/assets/14e1e50b-43c8-471b-b3e6-3f2b56dd79bd" />

---

# Key Engineering Learnings

* Private RDS access via VPN
* Terraform modular infrastructure
* AWS networking constraints (AZ coverage)
* Certificate‑based VPN auth
* Split‑tunnel configuration
* Local ingestion into private cloud DB
* Medallion data modeling

---

#  Real‑World Parallels

This architecture matches:

* Fintech internal databases
* SaaS analytics backends
* Enterprise BI platforms
* Secure data warehouses

---

#  How to Reproduce

1. Deploy infra

```
cd terraform/environments/dev
terraform init
terraform apply
```

<img width="1680" height="604" alt="image" src="https://github.com/user-attachments/assets/cb21b689-24c6-44b0-983b-fc3eb934982a" />


2. Export VPN certs

```
terraform output -raw client_certificate > client.crt
terraform output -raw client_private_key > client.key
terraform output -raw ca_certificate > ca.crt
```
<img width="1680" height="699" alt="image" src="https://github.com/user-attachments/assets/f242feda-87a9-4f1e-a7c7-a44bd1319289" />


3. Append certs to .ovpn

4. Connect AWS VPN Client

5. Connect pgAdmin

6. Run ingestion

```
python3 scripts/generate_data.py
```

7. Run SQL transforms

#  Project Outcome

* Private cloud database
* VPN‑restricted access
* Local ingestion
* Analytics modeling
---
<img width="1680" height="236" alt="image" src="https://github.com/user-attachments/assets/1e064c2f-3533-47b4-871b-8c2a3037edeb" />

<img width="1680" height="397" alt="image" src="https://github.com/user-attachments/assets/af2122b0-c29f-46c6-8a7d-7e9db510c5f4" />

<img width="1680" height="770" alt="image" src="https://github.com/user-attachments/assets/7c4cfe7a-2156-4e63-9166-30ec9412e47f" />

#  Future Enhancements

* dbt transformations
* Airflow orchestration
* CDC from RDS
* S3 data lake
* Redshift warehouse
* BI dashboards

---

#  Summary

This project demonstrates how to build and access a private AWS PostgreSQL database using Client VPN and implement a full data engineering workflow from ingestion to analytics — mirroring real enterprise data platform architecture.
