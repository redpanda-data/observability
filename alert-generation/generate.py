import os
import yaml
from pathlib import Path


def generate_grafana_alerts():
    alert_definitions = os.environ.get('ALERT_DEFINITIONS_YAML_FILE_LOCATION')
    alerts = yaml.safe_load(Path(alert_definitions).read_text())["rules"]

    rules = {}

    for alert in alerts:
        rule = yaml.safe_load(Path("templates/grafana-export-rule-template.yml").read_text())
        rule["uid"] = alert["uid"]
        rule["title"] = alert["alert"]
        rule["data"][0]["model"]["expr"] = alert["expr"]
        rule["data"][2]["model"]["conditions"][0]["evaluator"]["type"] = alert["comparison"]
        rule["data"][2]["model"]["conditions"][0]["evaluator"]["params"][0] = alert["threshold"]
        rule["for"] = alert["for"]
        rule["labels"] = alert["labels"]
        rule["annotations"] = alert["annotations"]
        rule["data"][0]["datasourceUid"] = "P1809F7CD0C75ACF3"
        rule["data"][0]["model"]["datasource"]["uid"] = "P1809F7CD0C75ACF3"
        if alert["folder"] not in rules:
            rules[alert["folder"]] = []
        rules[alert["folder"]].append(rule)

    groups = []

    for folder in rules.keys():
        group = yaml.safe_load(Path("templates/grafana-export-group-template.yml").read_text())
        group["folder"] = folder
        group["name"] = folder
        for rule in rules[folder]:
            group["rules"].append(rule)
        groups.append(group)

    export = yaml.safe_load(Path("templates/grafana-export-header-template.yml").read_text())
    export["groups"] = groups

    with open(os.environ.get('GRAFANA_ALERTS_YAML_FILE_LOCATION'), 'w') as outfile:
        yaml.dump(export, outfile, width=500)


def convert_comparison(comparison):
    if comparison == "lt":
        return "<"
    elif comparison == "gt":
        return ">"
    else:
        raise ValueError("Don't know how to convert unknown comparison function: {}".format(comparison))


def generate_prometheus_alerts():
    alert_definitions = os.environ.get('ALERT_DEFINITIONS_YAML_FILE_LOCATION')
    alerts = yaml.safe_load(Path(alert_definitions).read_text())["rules"]

    for alert in alerts:
        alert.pop("uid")
        alert.pop("folder")
        alert.pop("evaluation_group")
        alert["expr"] = "({}) {} {}".format(alert["expr"], convert_comparison(alert["comparison"]), alert["threshold"])
        alert.pop("comparison")
        alert.pop("threshold")

    export = yaml.safe_load(Path("templates/prometheus-export-template.yml").read_text())
    export["groups"][0]["rules"] = alerts

    prometheus_alerts = os.environ.get('PROMETHEUS_ALERTS_YAML_FILE_LOCATION')
    with open(prometheus_alerts, 'w') as outfile:
        yaml.dump(export, outfile, width=500)


generate_grafana_alerts()
generate_prometheus_alerts()


