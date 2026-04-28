resource "docker_image" "mosquitto" {
  name         = "eclipse-mosquitto:2.0.18"
  keep_locally = true
}

resource "docker_network" "mosquitto" {
  name   = "mosquitto"
  driver = "bridge"
}

resource "random_password" "mosquitto" {
  length  = 32
  special = false
}

module "mosquitto" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-mosquitto.git?ref=1.3.0"

  identifier = "mosquitto"
  image_id   = docker_image.mosquitto.image_id

  # Networking

  network_id = docker_network.mosquitto.id

  # Storage

  data_directory = "/data/mosquitto"

  # Authentication

  username = "mosquitto"
  password = random_password.mosquitto.result
}
