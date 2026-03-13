# Mosquitto Terraform Module (Dockerized)

Manage Mosquitto MQTT broker.

* Runs in bridge networking mode
* Persists data and logs directories
* Exposes listener and WebSocket ports
* Configuration rendered via Jinja templates
* Manages a dedicated Linux user/group for the daemon

## Usage

See [examples/default](examples/default) for a complete working configuration.

```hcl
module "mosquitto" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-mosquitto.git?ref=1.1.0"

  identifier     = "mosquitto"
  enabled        = true
  image_id       = docker_image.mosquitto.image_id
  data_directory = "/data/mosquitto"

  # Logging

  log_types = ["error", "warning", "notice", "information"]

  # Authentication

  username = "mosquitto"
  password = random_password.mosquitto.result

  # Networking

  hosts      = { "myserver" = "10.0.0.1" }
  network_id = docker_network.mosquitto.id
}
```

## Data layout

All persistent data lives under `data_directory`:

```
data_directory/
├── config/  # Generated configuration files (entrypoint.sh, mosquitto.conf)
├── data/    # Mosquitto persistent data
└── logs/    # Mosquitto log files
```

## Changing `app_uid` / `app_gid`

The `app_uid` and `app_gid` values are baked into three places:

1. The Linux user/group created on the host (`linux_user` / `linux_group` resources).
2. The `user` attribute of the container process.
3. The `chown` provisioner that sets ownership of the data and logs directories.

**Caveat — existing data directories**: The `chown` provisioner only runs on initial
resource creation (or when `replace_triggered_by` fires). If you change `app_uid` /
`app_gid` on an already-deployed instance, Terraform will recreate the Linux user and
group but will **not** re-chown the data on disk. The container will then start as the
new UID/GID but find files owned by the old one, causing permission errors.

**Safe migration procedure**:
1. Stop the container (`enabled = false`, `terraform apply`).
2. Manually `chown -R <new_uid>:<new_gid>` the `data_directory` subtree on the host.
3. Update `app_uid` / `app_gid` and re-enable (`enabled = true`, `terraform apply`).

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | `string` | — | Unique name for resources (must match `^[a-z]+(-[a-z0-9]+)*$`). |
| `enabled` | `bool` | — | Start or stop the container. |
| `wait` | `bool` | `false` | Wait for the container to reach a healthy state after creation. |
| `image_id` | `string` | — | [Mosquitto](https://hub.docker.com/_/eclipse-mosquitto/tags) Docker image's ID. |
| `data_directory` | `string` | — | Host path for persistent volumes. |
| `app_uid` | `number` | `1883` | UID of the user running the container and owning the data directories. |
| `app_gid` | `number` | `1883` | GID of the user running the container and owning the data directories. |
| `privileged` | `bool` | `false` | Run the container in privileged mode. |
| `cap_add` | `set(string)` | `[]` | Linux capabilities to add to the container. |
| `cap_drop` | `set(string)` | `[]` | Linux capabilities to drop from the container. |
| `log_types` | `list(string)` | `["error", "warning", "notice", "information"]` | Log types to enable. |
| `username` | `string` | — | MQTT authentication username. |
| `password` | `string` | — | MQTT authentication password (sensitive). |
| `hosts` | `map(string)` | `{}` | Extra `/etc/hosts` entries for the container. |
| `network_id` | `string` | — | Docker network to attach to. |
| `listener_port` | `number` | `1883` | Host port for the MQTT listener. |
| `websocket_port` | `number` | `9001` | Host port for the MQTT WebSocket. |

## Outputs

| Name | Description |
|------|-------------|
| `app_user` | Linux user resource for the daemon. |
| `app_group` | Linux group resource for the daemon. |
| `host` | Container hostname. |
| `listener_port` | MQTT listener port. |
| `websocket_port` | MQTT WebSocket port. |
| `username` | MQTT username. |
| `password` | MQTT password (sensitive). |

## Requirements

* Terraform >= 1.6
* [kreuzwerker/docker](https://github.com/kreuzwerker/terraform-provider-docker) >= 3.0.2
* [NikolaLohinski/jinja](https://github.com/NikolaLohinski/terraform-provider-jinja) >= 1.17.0
* [mavidser/linux](https://github.com/mavidser/terraform-provider-linux) >= 1.0.2
* [hashicorp/local](https://github.com/hashicorp/terraform-provider-local) >= 2.4.1

## References

* https://hub.docker.com/_/eclipse-mosquitto
* https://github.com/eclipse/mosquitto
