output "repository_url" {
  value       = github_repository.repo.html_url
  description = "The URL of the created repository"
}

output "repository_ssh_clone_url" {
  value       = github_repository.repo.ssh_clone_url
  description = "The SSH clone URL of the created repository"
}
