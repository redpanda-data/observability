local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';
local sectionName = 'Resource Quota (Soft Limits)';

{
  row::
    grafonnet.panel.row.new(sectionName)
    + grafonnet.panel.row.gridPos.withW(24)
    + grafonnet.panel.row.gridPos.withH(1),

  panels(datasource):: [
      // Section header
      common.sectionHeaderPanel(sectionName),

      // Partition Quota
      common.gaugePanel(
        'Partition Quota',
        [
          common.prometheusQuery(
            '(sum(redpanda_cluster_partitions{redpanda_cloud_data_cluster_name=~"${data_cluster}"}) / sum(redpanda_serverless_resource_limit{resource="partitions", redpanda_cloud_data_cluster_name=~"${data_cluster}"})) * 100',
            'Partition Usage'
          ),
        ]
      )
      + grafonnet.panel.gauge.gridPos.withW(5)
      + grafonnet.panel.gauge.gridPos.withH(5),

      // Topic Quota
      common.gaugePanel(
        'Topic Quota',
        [
          common.prometheusQuery(
            '(sum (redpanda_cluster_topics{redpanda_cloud_data_cluster_name=~"${data_cluster}"}) / sum(redpanda_serverless_resource_limit{resource="topics", redpanda_cloud_data_cluster_name=~"${data_cluster}"})) * 100',
            'Partition Usage'
          ),
        ]
      )
      + grafonnet.panel.gauge.gridPos.withW(4)
      + grafonnet.panel.gauge.gridPos.withH(5),

      // Ingress Quota
      common.gaugePanel(
        'Ingress Quota',
        [
          common.prometheusQuery(
            '(sum (rate(redpanda_serverless_ingress_bytes_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[5m])) / sum (redpanda_serverless_resource_limit{resource="ingress", redpanda_cloud_data_cluster_name=~"${data_cluster}"})) * 100',
            'Ingress Rate Usage'
          ),
        ]
      )
      + grafonnet.panel.gauge.gridPos.withW(4)
      + grafonnet.panel.gauge.gridPos.withH(5),

      // Egress Quota
      common.gaugePanel(
        'Egress Quota',
        [
          common.prometheusQuery(
            '(sum (rate(redpanda_serverless_egress_bytes_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[5m])) / sum (redpanda_serverless_resource_limit{resource="egress", redpanda_cloud_data_cluster_name=~"${data_cluster}"})) * 100',
            'Egress Rate Usage'
          ),
        ]
      )
      + grafonnet.panel.gauge.gridPos.withW(4)
      + grafonnet.panel.gauge.gridPos.withH(5),

      // Connection Quota
      common.gaugePanel(
        'Connection Quota',
        [
          common.prometheusQuery(
            '(sum (redpanda_serverless_connections_active{redpanda_cloud_data_cluster_name=~"${data_cluster}"}) / sum(redpanda_serverless_resource_limit{resource="connections", redpanda_cloud_data_cluster_name=~"${data_cluster}"})) * 100',
            'Connection Limit'
          ),
        ]
      )
      + grafonnet.panel.gauge.gridPos.withW(4)
      + grafonnet.panel.gauge.gridPos.withH(5),
  ],
}
