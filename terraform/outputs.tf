output "repository_url" {
  value = can(data.github_repository.existing_repo.id) ? data.github_repository.existing_repo.html_url : github_repository.homelab[0].html_url
}
