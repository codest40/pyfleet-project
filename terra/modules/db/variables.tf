# =======================================================
# DB Module v1 - Pyfleet
# =======================================================

# -------------------------
# Networking
# -------------------------
variable "vpc_id" {
  description = "VPC ID where the DB lives"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for DB"
  type        = list(string)
}

variable "app_security_group_ids" {
  description = "Security Group ID of app (for DB access)"
  type        = list(string)
}

# -------------------------
# DB Settings
# -------------------------
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "pyfleet"
}

variable "db_username" {
  description = "Master username"
  type        = string
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Storage in GB"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable multi-AZ for production resilience"
  type        = bool
  default     = true
}

variable "engine_version" {
  description = "Postgres version"
  type        = string
  default     = "15.15"
}

variable "replica_count" {
  description = "Number of read replicas"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
