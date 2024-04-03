variable "vault_name" {
  type        = string
  description = "name of vault"
}
variable "enabled" {
  type        = bool
  description = "value"    
}


variable "vault_force_destroy" {
  type        = bool
  description = "value"
}

variable "kms_key_description" {
  type    = string
 
}


variable "enable_key_rotation" {
  type        = bool
  description = "value"
 
}
variable "tags" {
  type        = map(string)
  description = "value"
}

variable "kms_key_deletion_window_in_days" {
  type = number
 
}

variable "aws_backup_plan_name" {
  type    = string
  
}

variable "backup_rules" {
  description = "List of backup rules with different schedules for different resources"
  type = map(object({
    rule_name         = string #(Required) An display name for a backup rule.
    schedule          = string
    start_window      = number
    completion_window = number


  }))

}

variable "WindowsVSS" {
  #type = bool

}
variable "WindowsVSS1" {
  type    = string
  default = "enabled"
}

variable "aws_iam_rule_name" {
  type    = string
}

variable "iam_policy_name" {
  type    = string

}

variable "aws_backup_selection_name" {
  type    = string
  
}

#To allow user to choose which backup selection to use
variable "backup_selections" {
  type = map(object({
    resources     = list(string)
    not_resources = list(string)

    selection_tags = map(object({
      type  = string
      key   = string
      value = string
    }))

    condition = map(any)

    # condition = map(object({
    #   string_equals = object({
    #     key   = string
    #     value = string
    #   })
    #   string_like = object({
    #     key   = string
    #     value = string
    #   })
    #   string_not_equals = object({
    #     key   = string
    #     value = string
    #   })
    #   string_not_like = object({
    #     key   = string
    #     value = string
    #   })
    # }))
  }))
  description = "Map of backup selections with their configurations including conditions"
}

# Users can specify this variable to select a specific backup selection.
variable "selected_backup_selection_key" {
  description = "Key of the selected backup selection"
  type        = string
}
