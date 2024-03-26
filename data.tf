# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["backup.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# output "aws_iam_policy" {
#   value = data.aws_iam_policy_document.assume_role.id
# }
# output "aws_test" {
#   value = data.aws_iam_policy_document.assume_role.json
# }

# locals {

#   # Rule
#   rule = var.rule_name == null ? [] : [
#     {
#       name              = var.rule_name
#       target_vault_name = var.vault_name != null ? var.vault_name : "Default"
#       schedule          = var.rule_schedule
#       start_window      = var.rule_start_window
#       completion_window = var.rule_completion_window
#       lifecycle = var.rule_lifecycle_cold_storage_after == null ? {} : {
#         cold_storage_after = var.rule_lifecycle_cold_storage_after
#         delete_after       = var.rule_lifecycle_delete_after
#       }
#       enable_continuous_backup = var.rule_enable_continuous_backup
#       recovery_point_tags      = var.rule_recovery_point_tags
#     }
#   ]

#   # Rules
#   rules = concat(local.rule, var.rules)

# }

# # Rules
#   dynamic "rule" {
#     for_each = local.rules
#     content {
#       rule_name                = lookup(rule.value, "name", null)
#       target_vault_name        = lookup(rule.value, "target_vault_name", null) != null ? rule.value.target_vault_name : var.vault_name != null ? aws_backup_vault.ab_vault[0].name : "Default"
#       schedule                 = lookup(rule.value, "schedule", null)
#       start_window             = lookup(rule.value, "start_window", null)
#       completion_window        = lookup(rule.value, "completion_window", null)
#       enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", null)
#       recovery_point_tags      = length(lookup(rule.value, "recovery_point_tags", {})) == 0 ? var.tags : lookup(rule.value, "recovery_point_tags")

#       # Lifecycle
#       dynamic "lifecycle" {
#         for_each = length(lookup(rule.value, "lifecycle", {})) == 0 ? [] : [lookup(rule.value, "lifecycle", {})]
#         content {
#           cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
#           delete_after       = lookup(lifecycle.value, "delete_after", 90)
#         }
#       }

#       # Copy action
#       dynamic "copy_action" {
#         for_each = lookup(rule.value, "copy_actions", [])
#         content {
#           destination_vault_arn = lookup(copy_action.value, "destination_vault_arn", null)

#           # Copy Action Lifecycle
#           dynamic "lifecycle" {
#             for_each = length(lookup(copy_action.value, "lifecycle", {})) == 0 ? [] : [lookup(copy_action.value, "lifecycle", {})]
#             content {
#               cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
#               delete_after       = lookup(lifecycle.value, "delete_after", 90)
#             }
#           }
#         }
#       }
#     }