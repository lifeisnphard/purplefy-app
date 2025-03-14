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
          composer_additional_args = ""
          tag_suffix = "wp-dev"
        },
        {
          target = "prod"
          composer_additional_args = "--no-dev"
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
  args = {
    COMPOSER_ADDITIONAL_ARGS = environment.composer_additional_args
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
