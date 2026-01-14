
variable "project_name" {
  description = "Project tag used for cost allocation"
  type        = string
}

variable "daily_budget_amount" {
  description = "Daily cost budget in USD"
  type        = number
}

variable "alert_emails" {
  description = "Email addresses to receive cost alerts"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
