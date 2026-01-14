# ============================================================
#  NETWORK MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The Network module provisions the foundational AWS networking
layer for the PyFleet platform.

It is designed to support a highly available, secure, and
scalable application architecture using best-practice VPC
isolation and subnet tiering.

This module is intentionally opinionated: it enforces clear
separation between public and private workloads while remaining
flexible through structured inputs.


# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## Core Networking
- Dedicated VPC with DNS support enabled
- Internet Gateway for public internet access


## Subnet Architecture (per Availability Zone)

For each configured AZ, the module creates four subnets:

+-------------------+--------------------------------------+
| Subnet Type       | Purpose                              |
+-------------------+--------------------------------------+
| Public ALB        | Internet-facing Application LB       |
| Public Bastion    | Secure SSH access point              |
| Private App       | Application servers (ASG / ECS)      |
| Private DB        | Databases (RDS / replicas)           |
+-------------------+--------------------------------------+

Results in:
- Multi-AZ high availability
- Strict isolation between tiers


## NAT & Routing
- One NAT Gateway per AZ (fault-tolerant)
- Dedicated route tables:
  - Single public route table (IGW)
  - Per-AZ private route tables (NAT-backed)
- Explicit route table associations for every subnet


# ------------------------------------------------------------
#  WHY THIS DESIGN
# ------------------------------------------------------------

## 1. Security by Default
- App and DB workloads never receive public IPs
- Internet access for private resources is egress-only via NAT
- Bastion hosts isolated in their own public subnets


## 2. High Availability
- Subnets and NAT Gateways deployed per AZ
- AZ-specific route tables prevent cross-AZ dependencies


## 3. Clear Separation of Concerns
- Public traffic (ALB, Bastion)
- Private workloads (App, DB)
- Networking fully isolated from compute and edge modules


## 4. Reusable & Environment-Agnostic
- CIDR ranges and AZ layouts are data-driven
- Same module supports dev, staging, and prod environments


# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------

## Availability Zone Mapping

The module uses a structured `azs` input:

azs = [
  {
    name           = "us-east-1a"
    public_bastion = "10.0.1.0/24"
    public_alb     = "10.0.2.0/24"
    private_app    = "10.0.11.0/24"
    private_db     = "10.0.21.0/24"
  }
]

This enables:
- Predictable CIDR allocation
- for_each-based resource creation
- Easy scaling to additional AZs


## Traffic Flow

### Inbound Traffic
Internet
   |
   v
ALB (Public Subnet)
   |
   v
App Servers (Private App Subnet)


### Outbound Traffic
Private App / DB
   |
   v
NAT Gateway (Same AZ)
   |
   v
Internet


### Administrative Access
Your IP
   |
   v
Bastion Host (Public Bastion Subnet)
   |
   v
Private App / DB


# ------------------------------------------------------------
#  INPUTS
# ------------------------------------------------------------
+------------------+--------------------------------------+
| Variable         | Description                          |
+------------------+--------------------------------------+
| vpc_cidr         | CIDR block for the VPC               |
| azs              | AZ definitions and subnet CIDRs      |
| enable_nat       | Toggle NAT Gateways (default: true) |
| tags             | Common resource tags                 |
+------------------+--------------------------------------+


# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
This module exposes networking primitives used across PyFleet:

- vpc_id
- public_alb_subnets
- public_bastion_subnets
- private_app_subnets
- private_db_subnets
- nat_gateway_ids
- igw_id
- public_route_table_ids
- private_route_table_ids

Consumed by:
- ALB
- ASG
- Bastion
- RDS
- Monitoring
- Security & IAM-dependent modules


# ------------------------------------------------------------
#  DESIGN NOTES & TRADE-OFFS
# ------------------------------------------------------------
- One NAT Gateway per AZ increases cost but avoids single-AZ
  failure modes
- Explicit route tables ensure predictable traffic paths
- CIDRs are not auto-calculated to maintain production control


# ------------------------------------------------------------
#  SUMMARY
# ------------------------------------------------------------
This module establishes a production-ready AWS network
foundation that prioritizes:

- Security
- Availability
- Scalability
- Clarity

It serves as the backbone of the PyFleet infrastructure,
allowing higher-level modules to focus purely on compute,
traffic management, and application logic.
