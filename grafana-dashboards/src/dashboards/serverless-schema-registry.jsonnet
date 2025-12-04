local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';
local sectionName = 'Schema Registry';

{
  row::
    grafonnet.panel.row.new(sectionName)
    + grafonnet.panel.row.gridPos.withW(24)
    + grafonnet.panel.row.gridPos.withH(1),

  panels(datasource):: [
      // Section header
      common.sectionHeaderPanel(sectionName),

      // Schemas
      common.statPanel(
        'Schemas',
        [
          common.prometheusQuery(
            'sum(redpanda_schema_registry_cache_schema_count{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Total Schemas'
          ),
        ]
      )
      + grafonnet.panel.stat.gridPos.withW(3)
      + grafonnet.panel.stat.gridPos.withH(6)
      + grafonnet.panel.stat.standardOptions.withUnit('none'),

      // Schema Registry Request Rate
      common.timeseriesPanel(
        'Schema Registry Request Rate',
        [
          common.prometheusQuery(
            'sum by (listener) (rate(redpanda_schema_registry_request_latency_seconds_count{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'Request Rate ({{listener}})'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(7)
      + grafonnet.panel.timeSeries.gridPos.withH(6)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('reqps')
      + grafonnet.panel.timeSeries.standardOptions.withDecimals(2),

      // Schema Registry P95 Latency
      common.timeseriesPanel(
        'Schema Registry P95 Latency',
        [
          common.prometheusQuery(
            'histogram_quantile(0.95, sum by (le, listener) (rate(redpanda_schema_registry_request_latency_seconds_bucket{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))) * 1000',
            'P95 Latency ({{listener}})'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(7)
      + grafonnet.panel.timeSeries.gridPos.withH(6)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('ms')
      + grafonnet.panel.timeSeries.standardOptions.withDecimals(2),

      // Schema Registry Error Rate
      common.timeseriesPanel(
        'Schema Registry Error Rate',
        [
          common.prometheusQuery(
            'sum(rate(redpanda_schema_registry_request_errors{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'Error Rate'
          ),
        ],
        { fillOpacity: 0 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(7)
      + grafonnet.panel.timeSeries.gridPos.withH(6)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('errps'),
  ],
}
