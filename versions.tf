terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }

    jinja = {
      source  = "NikolaLohinski/jinja"
      version = ">= 2.0.0"
    }

    linux = {
      source  = "mavidser/linux"
      version = ">= 1.0.2"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }
  }
}
