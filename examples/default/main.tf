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
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-mosquitto.git?ref=1.1.0"

  identifier     = "mosquitto"
  enabled        = true
  image_id       = docker_image.mosquitto.image_id
  data_directory = "/data/mosquitto"

  log_types = ["error", "warning", "notice", "information"]

  username = "mosquitto"
  password = random_password.mosquitto.result

  network_id = docker_network.mosquitto.id
}
