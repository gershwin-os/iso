#!/bin/sh

# Define an array of repository URLs
repos=(
  "https://github.com/gershwin-os/root.git"
  "https://github.com/gershwin-os/system.git"
  "https://github.com/gershwin-os/developer.git"
  "https://github.com/gershwin-os/applications.git"
)

# Loop through each repository URL
for repo_url in "${repos[@]}"; do
  # Extract repository name from URL
  repo_name=$(basename "$repo_url" .git)
  
  # Check if the repository directory already exists
  if [ ! -d "$repo_name" ]; then
    # Clone repository including submodules
    git clone --recurse-submodules "$repo_url"
    echo "Cloned $repo_url"
  else
    echo "Repository $repo_name already exists, skipping clone."
  fi
done
