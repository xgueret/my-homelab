resource "github_repository" "homelab" {
  count       = can(data.github_repository.existing_repo.id) ? 0 : 1
  name        = var.repository_name
  description = var.repository_description
  visibility  = var.visibility
}

# Add multiple collaborators to the repository using for_each
resource "github_repository_collaborator" "homelab_collaborators" {
  for_each   = var.collaborators
  repository = can(data.github_repository.existing_repo.id) ? data.github_repository.existing_repo.name : github_repository.homelab[0].name
  username   = each.key  # Username of the collaborator
  permission = each.value  # Permission level for the collaborator (pull, push, or admin)
}