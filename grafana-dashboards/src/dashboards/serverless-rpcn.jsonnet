local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';
local sectionName = 'Redpanda Connect';

{
  row::
    grafonnet.panel.row.new(sectionName)
    + grafonnet.panel.row.gridPos.withW(24)
    + grafonnet.panel.row.gridPos.withH(1),

  panels(datasource):: [
      // Section header
      common.sectionHeaderPanel(sectionName),

      // Running Pipelines
      common.statPanel(
        'Running Pipelines',
        [
          common.prometheusQuery(
            'count(sum by (pipeline_id) (input_connection_up{redpanda_cloud_data_cluster_name=~"${data_cluster}"}))',
            'Running Pipelines'
          ),
        ]
      )
      + grafonnet.panel.stat.gridPos.withW(3)
      + grafonnet.panel.stat.gridPos.withH(7)
      + grafonnet.panel.stat.standardOptions.withUnit('none'),

      // Input Throughput
      common.timeseriesPanel(
        'Input Throughput',
        [
          common.prometheusQuery(
            'sum by (pipeline_id) (rate(input_received{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            '{{pipeline_id}}'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(10)
      + grafonnet.panel.timeSeries.gridPos.withH(7)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('recps')
      + grafonnet.panel.timeSeries.panelOptions.withDescription('Message rate for data flowing into Redpanda Connect pipelines'),

      // Output Throughput
      common.timeseriesPanel(
        'Output Throughput',
        [
          common.prometheusQuery(
            'sum by (pipeline_id) (rate(output_sent{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            '{{pipeline_id}}'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(11)
      + grafonnet.panel.timeSeries.gridPos.withH(7)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('recps')
      + grafonnet.panel.timeSeries.standardOptions.color.withMode('continuous-BlPu')
      + grafonnet.panel.timeSeries.panelOptions.withDescription('Message rate for data flowing out of Redpanda Connect pipelines'),

      {},  // Line break

      // Input Connections Down
      common.timeseriesPanel(
        'Input Connections Down',
        [
          common.prometheusQuery(
            'sum(input_connection_failed{redpanda_cloud_data_cluster_name=~"${data_cluster}"}) OR sum(input_connection_lost{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Total Input Down'
          ),
        ],
        { fillOpacity: 0 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(6)
      + grafonnet.panel.timeSeries.gridPos.withH(5)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('none'),

      // Output Connections Down
      common.timeseriesPanel(
        'Output Connections Down',
        [
          common.prometheusQuery(
            'sum(output_connection_failed{redpanda_cloud_data_cluster_name=~"${data_cluster}"}) OR sum(output_connection_lost{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Total Output Down'
          ),
        ],
        { fillOpacity: 0 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(6)
      + grafonnet.panel.timeSeries.gridPos.withH(5)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('none'),

      // Processor Errors
      common.timeseriesPanel(
        'Processor Errors',
        [
          common.prometheusQuery(
            'sum(processor_error{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Total Processor Error'
          ),
        ],
        { fillOpacity: 0 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(6)
      + grafonnet.panel.timeSeries.gridPos.withH(5)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('none'),

      // Output Errors
      common.timeseriesPanel(
        'Output Errors',
        [
          common.prometheusQuery(
            'sum(output_error{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Total Output Errors'
          ),
        ],
        { fillOpacity: 0 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(6)
      + grafonnet.panel.timeSeries.gridPos.withH(5)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('none'),

      {},  // Line break

      // Input P90 Latency
      common.timeseriesPanel(
        'Input P90 Latency (ms)',
        [
          common.prometheusQuery(
            'avg by (pipeline_id) (input_latency_ns{redpanda_cloud_data_cluster_name=~"${data_cluster}", quantile="0.9"}) / 1000000',
            '{{pipeline_id}}'
          ),
          common.prometheusQuery(
            'histogram_quantile(0.95, sum by (le) (rate(output_latency_ns_bucket{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))) / 1000000',
            'Output P95 Latency'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(12)
      + grafonnet.panel.timeSeries.gridPos.withH(8)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('ms')
      + grafonnet.panel.timeSeries.panelOptions.withDescription('P95 latency for messages traveling through the connector input stages'),

      // Output P90 Latency
      common.timeseriesPanel(
        'Output P90 Latency (ms)',
        [
          common.prometheusQuery(
            'avg by (pipeline_id) (output_latency_ns{redpanda_cloud_data_cluster_name=~"${data_cluster}", quantile="0.9"}) / 1000000',
            '{{pipeline_id}}'
          ),
          common.prometheusQuery(
            'histogram_quantile(0.95, sum by (le) (rate(output_latency_ns_bucket{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))) / 1000000',
            'Output P95 Latency'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(12)
      + grafonnet.panel.timeSeries.gridPos.withH(8)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('ms')
      + grafonnet.panel.timeSeries.standardOptions.color.withMode('continuous-BlPu')
      + grafonnet.panel.timeSeries.panelOptions.withDescription('P95 latency for messages traveling through the connector output stages'),
  ],
}
