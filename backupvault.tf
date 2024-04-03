// Define the AWS Backup vault resource
resource "aws_backup_vault" "backup_vault" {
  #count         = var.enabled && var.vault_name != null ? 1 : 0
  name          = var.vault_name
  kms_key_arn   = aws_kms_key.kms_key.arn #Create it then ref it
  force_destroy = var.vault_force_destroy
  tags          = var.tags

}

resource "aws_kms_key" "kms_key" {
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  tags                    = var.tags
}

resource "aws_backup_plan" "backup_plan" {
  name = var.aws_backup_plan_name
  dynamic "rule" {
    for_each = var.backup_rules
    content {
      rule_name         = lookup(rule.value, "rule_name", null)
      target_vault_name = aws_backup_vault.backup_vault.name
      schedule          = lookup(rule.value, "schedule", null)
      start_window      = lookup(rule.value, "start_window", null)
      completion_window = lookup(rule.value, "complete_window", null)
      # lifecycle {
      #   cold_storage_after = lookup(rule.value, "cold_storage_after", null)
      #   delete_after       = lookup(rule.value, "delete_after", null)
      #   #opt_in_to_archive_for_supported_resources = false
      # }
    }
  }
  #put a condition
  #If VSS is enable then run this block
  dynamic "advanced_backup_setting" {
    #for_each = var.WindowsVSS == null ? var.WindowsVSS1 : var.WindowsVSS
    for_each = var.WindowsVSS == "enabled" ? [1] : []
    # condition == yes ? Abigail is star : Abigail is not a star

    #for_each = each.value.WindowsVSS ? each.value.WindowsVSS : []
    content {
      backup_options = {
        WindowsVSS = var.WindowsVSS
      }
      resource_type = "EC2"
    }
  }


}

resource "aws_iam_role" "role" {
  name               = var.aws_iam_rule_name
  assume_role_policy = aws_iam_policy.policy.policy #data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.role.name
}

resource "aws_iam_policy" "policy" {
  name        = var.iam_policy_name
  path        = "/"
  description = "AWS backup policy"
  policy      = file("iam-policy.json")
}


resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = aws_iam_role.role.arn
  name         = var.aws_backup_selection_name
  plan_id      = aws_backup_plan.backup_plan.id

  for_each = var.backup_selections
  #Allow user to pick which selection to use

  resources     = each.value.resources
  not_resources = each.value.not_resources

  dynamic "selection_tag" {
    for_each = each.value.selection_tags
    content {
      type  = selection_tag.value.type
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }

  dynamic "condition" {
    #for_each checks if conditions are defined for the backup selection. 
    #If conditions are defined (each.value.conditions != null), 
    #it creates a single-element list [1], otherwise, it creates an empty list [].
    for_each = each.value.condition != null ? [1] : []
    content {
      dynamic "string_equals" {
        #checks if string_equals conditions are defined. 
        #If they are (each.value.conditions.string_equals is not null), 
        #it iterates over the map of string_equals conditions. 
        #Otherwise, it uses an empty list [].
        for_each = each.value.condition != null ? [each.value.condition.string_equals] : []
        content {
          key   = string_equals.value["key"]
          value = string_equals.value["value"]
        }
      }
      dynamic "string_like" {
        for_each = each.value.condition != null ? [each.value.condition.string_like] : []
        content {
          key   = string_like.value["key"]
          value = string_like.value["value"]
        }
      }
      dynamic "string_not_equals" {
        for_each = each.value.condition != null ? [each.value.condition.string_not_equals] : []
        content {
          key   = string_not_equals.value["key"]
          value = string_not_equals.value["value"]
        }
      }
      dynamic "string_not_like" {
        for_each = each.value.condition != null ? [each.value.condition.string_not_like] : []
        content {
          key   = string_not_like.value["key"]
          value = string_not_like.value["value"]
        }
      }
    }
  }
}



