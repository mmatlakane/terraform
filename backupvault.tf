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


resource "aws_backup_plan" "example" {
  name = var.aws_backup_plan_name

  // Define dynamic blocks to create backup rules based on input variables
  dynamic "rule" {
    // Iterate over each backup rule specified in the input variable var.backup_rules
    for_each = var.backup_rules

    content {
      // Define attributes of each backup rule
      rule_name                = rule.value.name
      target_vault_name        = aws_backup_vault.backup_vault.name
      schedule                 = rule.value.schedule
      enable_continuous_backup = rule.value.enable_continuous_backup
      start_window             = rule.value.start_window
      completion_window        = rule.value.completion_window
      recovery_point_tags      = rule.value.recovery_point_tags
    #   copy_action {
    #     #lifecycle = rule.value.lifecycle
    #     lifecycle {
    #       delete_after                              = rule.value.delete_after
    #       cold_storage_after                        = rule.value.cold_storage_after
    #       opt_in_to_archive_for_supported_resources = rule.value.opt_in_to_archive_for_supported_resources
    #     }
    #     destination_vault_arn = aws_backup_vault.backup_vault.arn #rule.value.destination_vault_arn
    # }
    }
  }
}

# output "destination_vault_arn" {
#   value = aws_backup_vault.backup_vault.arn
# }

locals {
  destination_vault_arn = aws_backup_vault.backup_vault.arn
}

resource "aws_iam_role" "role" {
  name               = "example"
  assume_role_policy = aws_iam_policy.policy.policy #data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  policy_arn = aws_iam_policy.policy.arn #"arn:aws:iam::466021236912:role/service-role/AWSBackupDefaultServiceRole"
  role       = aws_iam_role.role.name
}

resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("iam-policy.json")
}

# resource "aws_backup_selection" "example" {
#     #CCreate iam role and policy
#     #Use data resource
#   iam_role_arn =  aws_iam_role.example.arn #"arn:aws:iam::466021236912:role/service-role/AWSBackupDefaultServiceRole"
#   #Make var
#   name         = "tf_example_backup_selection"
#   plan_id      = aws_backup_plan.example.id

#     #Resources is an array 
#   resources = [
#    # "arn:aws:ec2:eu-west-1:466021236912:instance/i-0b486b679d507f32d",
#     #"arn:aws:s3:::mbalcftestingbucket1232",
#     "arn:aws:dynamodb:af-south-1:466021236912:table/libery-srs_tf_lockid"
#   ]
# }

resource "aws_backup_selection" "example" {
  iam_role_arn = aws_iam_role.role.arn
  name         = "tf_example_backup_selection"
  plan_id      = aws_backup_plan.example.id

dynamic "selection_tag" {
    for_each = length(var.selection)
  
    content {
      type  = "STRINGEQUALS"
    key   = "BackupPlanTagValue"
    value = "True"
    }
    
}
condition {
    string_equals {
      key   = "aws:ResourceTag/Component"
      value = "rds"
    }
    string_like {
      key   = "aws:ResourceTag/Application"
      value = "app*"
    }
    string_not_equals {
      key   = "aws:ResourceTag/Backup"
      value = "false"
    }
    string_not_like {
      key   = "aws:ResourceTag/Environment"
      value = "test*"
    }
  }
  
}