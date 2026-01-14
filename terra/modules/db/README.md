# ============================================================
#  DATABASE MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The Database module provisions a secure PostgreSQL cluster
in private subnets for the PyFleet platform.

It supports:

- Multi-AZ deployment for high availability
- Read replicas for scaling read workloads
- Private networking with access only from application servers
- Tagged resources for easy identification and management

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## Security Group
- Allows inbound PostgreSQL traffic (port 5432) only from
  application security groups
- Allows all outbound traffic
- Tagged as `pyfleet-db-sg`

## DB Subnet Group
- Groups private subnets for RDS deployment
- Tagged as `pyfleet-db-subnet-group`

## RDS Instances
- **Primary DB**
  - PostgreSQL engine (configurable version, default 15.15)
  - Configurable instance class (default db.t3.medium)
  - Multi-AZ support for production resilience
  - Backups retained for 7 days
- **Read Replicas (Optional)**
  - Deployed in private subnets
  - Supports horizontal scaling for read-heavy workloads
  - Tagged for identification

# ------------------------------------------------------------
#  INPUTS
# ------------------------------------------------------------
+-------------------------+-----------------------------------------------------+
| Variable                | Description                                         |
+-------------------------+-----------------------------------------------------+
| vpc_id                  | ID of the VPC for DB deployment                     |
| private_subnet_ids       | List of private subnet IDs for database            |
| app_security_group_ids   | Security group IDs of application servers allowed  |
| db_name                 | Database name (default: pyfleet)                   |
| db_username             | Master username for DB                              |
| db_password             | Master password for DB (sensitive)                 |
| db_instance_class       | RDS instance type (default: db.t3.medium)          |
| db_allocated_storage    | Storage in GB (default: 20)                        |
| multi_az                | Enable multi-AZ deployment (default: true)         |
| engine_version          | PostgreSQL version (default: 15.15)                |
| replica_count           | Number of read replicas (default: 1)              |
| tags                    | Tags applied to all DB resources                   |
+-------------------------+-----------------------------------------------------+

# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
+-------------------------+-----------------------------------------------------+
| Output                  | Description                                         |
+-------------------------+-----------------------------------------------------+
| primary_db_endpoint     | Endpoint of the primary DB instance                |
| primary_db_port         | Port of the primary DB instance                    |
| replica_endpoints       | List of endpoints for read replicas                |
| db_security_group_id    | Security group ID associated with the DB           |
+-------------------------+-----------------------------------------------------+

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
- The security group ensures only application servers can communicate with the DB
- Primary DB instance can be deployed multi-AZ for resilience
- Optional read replicas provide horizontal scaling for read-heavy workloads
- DB instances are launched in private subnets for network isolation and security

# ------------------------------------------------------------
#  USAGE NOTES
# ------------------------------------------------------------
- Suitable for production workloads with secure, private PostgreSQL clusters
- Ensure application servers’ security groups allow DB connectivity
- Store database credentials securely for application access
- Multi-AZ and read replicas enhance availability and read performance
