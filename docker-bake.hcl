variable "REGISTRY" {
  default = "ghcr.io/lifeisnphard"
}

variable "IMAGE_NAME" {
  default = "purplefy-app"
}

variable "SERVICES" {
  default = {
    wordpress = {
      versions = [
        "latest",
        "0.1.0",
        "0.1",
      ]
      environments = [
        {
          target = "dev"
          args = {
            COMPOSER_ADDITIONAL_ARGS = ""
          }
          tag_suffix = "wp-dev"
        },
        {
          target = "prod"
          args = {
            COMPOSER_ADDITIONAL_ARGS = "--no-dev"
          }
          tag_suffix = "wp"
        }
      ]
    }
  }
}

function "generate_tags" {
  params = [versions, tag_suffix]
  result = [for version in versions: "${REGISTRY}/${IMAGE_NAME}:${version}-${tag_suffix}"]
}

target "wp" {
  name = "wp-${environment.target}"
  matrix = {
    environment = SERVICES.wordpress.environments
  }

  context = "./services/wordpress"
  dockerfile = "Dockerfile"
  target = environment.target
  args = environment.args
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  labels = {
    "org.opencontainers.image.source" = "https://github.com/lifeisnphard/purplefy-app"
    "org.opencontainers.image.description" = "Highly optimized WordPress image wiht Composer for dependency management"
    "org.opencontainers.image.author" = "carlos@viniciusferreira.com"
    "org.opencontainers.image.licenses" = "MIT"
  }
  tags = generate_tags(SERVICES.wordpress.versions, environment.tag_suffix)
}

group "default" {
  targets = [
    "wp",
  ]
}

group "prod" {
  targets = [
    "wp-prod",
  ]
}

group "dev" {
  targets = [
    "wp-dev",
  ]
}
