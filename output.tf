# Output the resources of the selected backup selection.
output "selected_backup_selection_resources" {
  value = aws_backup_selection.backup_selection[var.selected_backup_selection_key].resources
}

# Output the not_resources of the selected backup selection.
output "selected_backup_selection_not_resources" {
  value = aws_backup_selection.backup_selection[var.selected_backup_selection_key].not_resources
}

output "selected_backup_selection_conditions" {
  value = aws_backup_selection.backup_selection[var.selected_backup_selection_key].condition
}