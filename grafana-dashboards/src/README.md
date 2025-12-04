# Grafana Dashboards Generator

This directory contains Jsonnet source code for generating Grafana dashboards using [Grafonnet](https://grafana.github.io/grafonnet/).

## Prerequisites

Install the following tools:

- **jsonnet**: `brew install jsonnet` (macOS) or see [jsonnet.org](https://jsonnet.org/)
- **jsonnet-bundler (jb)**: `go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest`

## Build Dashboards

```bash
# Install dependencies
make install

# Generate JSON dashboards
make build
```

Generated dashboards will be created in the parent directory (`grafana-dashboards/`).

## Adding New Dashboards

Create a new `.jsonnet` file in `dashboards/` and add a build target in the `Makefile`:

See the `serverless.jsonnet` example for code organization.

## Importing Dashboards

The generated dashboards use datasource variables instead of hardcoded UIDs, making them portable across Grafana instances:

1. In Grafana, go to **Dashboards → Import**
2. Upload the JSON file
3. Select your Prometheus datasource when prompted

## Resources

- [Grafonnet Documentation](https://grafana.github.io/grafonnet/)
- [Jsonnet Tutorial](https://jsonnet.org/learning/tutorial.html)
