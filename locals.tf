# Retrieve the configuration of the selected backup selection.
locals {
  selected_backup_selection = var.backup_selections[var.selected_backup_selection_key]
}