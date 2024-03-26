variable "vault_name" {
  type        = string
  description = "name of vault"
  default     = "mbali_vault_name"
}
variable "enabled" {
  type        = bool
  description = "value"
  default     = true
}

# variable "vault_kms_key_arn" {
#  "arn:aws:kms:eu-west-1:466021236912:key/81ad16de-2b89-405b-bf21-39d54e0ed4aa" 
# }

variable "vault_force_destroy" {
  type        = bool
  description = "value"
  default     = false

}

variable "kms_key_description" {
  type    = string
  default = "Example KMS Key"
}


variable "enable_key_rotation" {
  type        = bool
  description = "value"
  default     = true
}
variable "tags" {
  type        = map(string)
  description = "value"
  default = {
    "Envirnment" = "Dev"
  }
}

variable "kms_key_deletion_window_in_days" {
  #type = 
  default = 7
}

variable "aws_backup_plan_name" {
  type    = string
  default = "tf_example_backup_plan"
}

variable "backup_rules" {
  
}
variable "selection"{

}










# variable "backup_rules" {
#   description = "List of backup rules with different schedules for different resources"
#   type = list(object({
#     name                     = string #(Required) An display name for a backup rule.
#     schedule                 = string
#     delete_after             = number
#     enable_continuous_backup = bool
#     start_window             = number
#     completion_window        = number
#     recovery_point_tags      = string
#     copy_action = list(object({
#       destination_vault_arn = string
#       lifecycle = list(object({
#         delete_after                              = number
#         cold_storage_after                        = number
#         opt_in_to_archive_for_supported_resources = bool
#       }))
#     }))
    # resources = list(object({
    #   name         = string
    #   arn          = string
    #   iam_role_arn = string
    # }))
#   }))

# }
