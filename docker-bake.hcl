variable "REGISTRY" {
  default = "ghcr.io/lifeisnphard"
}

variable "IMAGE_NAME" {
  default = "purplefy-app"
}

variable "VERSIONS" {
  default = ["latest", "0.1.0", "0.1"]
}

variable "ENVIRONMENTS" {
  default = ["dev", "prod"]
}

variable "OCI_LABELS" {
  default = {
    "org.opencontainers.image.source" = "https://github.com/lifeisnphard/purplefy-app"
    "org.opencontainers.image.description" = "Highly optimized WordPress image wiht Composer for dependency management"
    "org.opencontainers.image.author" = "carlos@viniciusferreira.com"
    "org.opencontainers.image.licenses" = "MIT"
  }
}

function "generate_tags" {
  params = [versions, suffix]
  result = [for version in versions: "${REGISTRY}/${IMAGE_NAME}:${version}-${suffix}"]
}

target "wp-base" {
  context = "."
  dockerfile = "docker/wordpress/Dockerfile"
  labels = OCI_LABELS
}

target "development" {
  inherits = ["wp-base"]
  target = "wp-dev"
  tags = generate_tags(VERSIONS, "wp-dev")
}

target "production" {
  inherits = ["wp-base"]
  target = "wp-prod"
  tags = generate_tags(VERSIONS, "wp")
  platforms = ["linux/amd64", "linux/arm64"]
}

target "debug" {
  inherits = ["wp-base"]
  target = "wp-debug"
  tags = generate_tags(VERSIONS, "wp-debug")
}

group "default" {
  targets = ["production"]
}

group "local" {
  targets = ["debug", "development"]
}

group "all" {
  targets = ["debug", "development", "production"]
}
