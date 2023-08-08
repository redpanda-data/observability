# Alert Generation

This is a sub-project of [Observability](https://github.com/redpanda-data/observability), which exists to help
create alert definition files for Prometheus and Grafana.

### I just want to add my own alerts - do I need this?

Probably not. All you need to do is modify the [alert definition file](../demo/config/alert-definitions.yml) with your
alerts and run `docker-compose up` - everything should work from there. If it doesn't, please open an issue!

### What is the format of the alert definition file?

It's YAML. It's a custom structure, but it's very close to the format used by
[Prometheus](../demo/config/prometheus/alert-rules.yml). The similarity is intentional, but it differs so that we can
also generate Grafana alerts relatively easily as well.

### What does the project do?

It reads a YAML [alert definition file](../demo/config/alert-definitions.yml) and writes 
out [alerts.yml](../demo/config/grafana/provisioning/alerting/alerts.yml) for Grafana and [alert-rules.yml](../demo/config/prometheus/alert-rules.yml)  It does that using a number of templates found in `alert-generation/templates`

### How is it configured?

Environment variables - see the command line example below. This helps when running the command in Docker / Kubernetes
environments.

# Usage

## Command line

```shell
# This is the alert definitions input file for processing
ALERT_DEFINITIONS_YAML_FILE_LOCATION=path/to/alert-definitions.yml

# This is where the Grafana alerts file should be written
GRAFANA_ALERTS_YAML_FILE_LOCATION=path/to/grafana/alerts.yml

# This is where the Prometheus alerts file should be written
PROMETHEUS_ALERTS_YAML_FILE_LOCATION=path/to/prometheus/alert-rules.yml

# This runs the alert generation process
python3 generate.py 
```

## Docker Compose

In order that the demo work with a simple `docker-compose up`, the alert generation is already integrated into the
[docker-compose.yml](../demo/docker-compose.yml). When docker compose is started, a pre-built image 
[pmwrp/alert-generation:0.1](https://hub.docker.com/r/pmwrp/alert-generation) is run, which performs the alert
generation process. This writes out new alert definitions for both Prometheus and Grafana into the
`../config` folder, which are used by their respective containers.

```yaml
version: '3.7'
services:
  # ... other services here
  generate-alert-configs:
    image: pmwrp/alert-generation:0.1
    environment:
      - "ALERT_DEFINITIONS_YAML_FILE_LOCATION=/config/alert-definitions.yml"
      - "GRAFANA_ALERTS_YAML_FILE_LOCATION=/config/grafana/provisioning/alerting/alerts.yml"
      - "PROMETHEUS_ALERTS_YAML_FILE_LOCATION=/config/prometheus/alert-rules.yml"
    volumes:
      - "./config:/config"
  # ... other services here
```

(This docker-compose.yaml snippet runs the alert generation process over the current [alert definition file](../demo/config/alert-definitions.yml) and writes out
[alerts.yml](../demo/config/grafana/provisioning/alerting/alerts.yml) for Grafana and [alert-rules.yml](../demo/config/prometheus/alert-rules.yml) for Prometheus.)