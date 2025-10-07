pfxdeploy() {
  echo "Deploying..."
  git status --porcelain | grep '^.[M]' | cut -c4- | grep -E '\.(json|groovy)$'
}
