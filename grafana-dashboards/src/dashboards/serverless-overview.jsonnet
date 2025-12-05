local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';
local sectionName = 'Redpanda Serverless Overview';

{
  row::
    grafonnet.panel.row.new(sectionName)
    + grafonnet.panel.row.gridPos.withW(24)
    + grafonnet.panel.row.gridPos.withH(1),

  panels(datasource):: [
      // Section header
      common.sectionHeaderPanel(sectionName),

      // Redpanda Version
      common.statPanel(
        'Redpanda Version',
        [
          common.prometheusQuery(
            'topk(1, last_over_time(redpanda_application_build{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[5m]))',
            '__auto'
          ),
        ],
        { textMode: 'name', graphMode: 'none' }
      )
      + grafonnet.panel.stat.gridPos.withW(6)
      + grafonnet.panel.stat.gridPos.withH(3)
      + grafonnet.panel.stat.options.withWideLayout(true)
      + grafonnet.panel.stat.standardOptions.withDisplayName('${__field.labels.redpanda_version}'),

      // Throughput
      common.timeseriesPanel(
        'Throughput',
        [
          common.prometheusQuery(
            'sum by (listener) (rate(redpanda_serverless_ingress_bytes_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'Ingress ({{listener}})'
          ),
          common.prometheusQuery(
            'sum by (listener) (rate(redpanda_serverless_egress_bytes_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'Egress ({{listener}})'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(9)
      + grafonnet.panel.timeSeries.gridPos.withH(8)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('Bps')
      + grafonnet.panel.timeSeries.panelOptions.withDescription('Data transferred from the clients to the Serverless Cluster (Ingress) and from the Serverless Cluster to the clients (Egress)'),

      // Records
      common.timeseriesPanel(
        'Records',
        [
          common.prometheusQuery(
            'sum(rate(redpanda_kafka_records_produced_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'Produced'
          ),
          common.prometheusQuery(
            'sum(rate(redpanda_kafka_records_fetched_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'Fetched'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(9)
      + grafonnet.panel.timeSeries.gridPos.withH(8)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('recps')
      + grafonnet.panel.timeSeries.panelOptions.withDescription('Number of records produced or fetched from the Serverless Cluster'),

      {},  // Line break

      // Topics
      common.statPanel(
        'Topics',
        [
          common.prometheusQuery(
            'sum(redpanda_cluster_topics{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Topics count'
          ),
        ]
      )
      + grafonnet.panel.stat.gridPos.withW(3)
      + grafonnet.panel.stat.gridPos.withH(5)
      + grafonnet.panel.stat.standardOptions.withUnit('none'),

      // Partitions
      common.statPanel(
        'Partitions',
        [
          common.prometheusQuery(
            'sum(redpanda_cluster_partitions{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Partition count'
          ),
        ],
        { colorMode: 'value', graphMode: 'area' }
      )
      + grafonnet.panel.stat.gridPos.withW(3)
      + grafonnet.panel.stat.gridPos.withH(5)
      + grafonnet.panel.stat.standardOptions.withUnit('none')
      + grafonnet.panel.stat.standardOptions.thresholds.withSteps([
        { color: 'green', value: 0 },
        { color: 'yellow', value: 4500 },
        { color: 'red', value: 5000 },
      ]),

      {},  // Line break

      // Consumers per Group
      common.timeseriesPanel(
        'Consumers per Group',
        [
          common.prometheusQuery(
            'sum(redpanda_kafka_consumer_group_consumers{redpanda_cloud_data_cluster_name=~"${data_cluster}"}) by (redpanda_group)',
            '{{redpanda_consumer_group}}'
          ),
        ]
      )
      + grafonnet.panel.timeSeries.gridPos.withW(7)
      + grafonnet.panel.timeSeries.gridPos.withH(7)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('none'),

      // Lag Sum per Consumer Group
      common.timeseriesPanel(
        'Lag Sum per Consumer Group',
        [
          common.prometheusQuery(
            'sum(redpanda_kafka_consumer_group_lag_sum{redpanda_cloud_data_cluster_name=~"${data_cluster}"}) by (redpanda_group)',
            '{{redpanda_group}}'
          ),
        ],
        { fillOpacity: 27 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(8)
      + grafonnet.panel.timeSeries.gridPos.withH(7)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('short')
      + grafonnet.panel.timeSeries.standardOptions.color.withMode('continuous-reds'),

      // Most Active Topics
      common.barChartPanel(
        'Most active topics',
        [
          common.prometheusQuery(
            'topk(6, sum by (redpanda_topic) (\n  rate(redpanda_kafka_records_produced_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]) + \n  rate(redpanda_kafka_records_fetched_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval])\n))',
            '__auto',
            { instant: true, range: false, exemplar: false, format: 'table' }
          ),
        ]
      )
      + grafonnet.panel.barChart.gridPos.withW(9)
      + grafonnet.panel.barChart.gridPos.withH(7)
      + grafonnet.panel.barChart.standardOptions.withUnit('ops')
      + grafonnet.panel.barChart.standardOptions.color.withMode('continuous-BlPu')
      + grafonnet.panel.barChart.options.withShowValue('never')
      + grafonnet.panel.barChart.panelOptions.withDescription('Total produce and fetch activities')
      + grafonnet.panel.barChart.queryOptions.withTransformations([
        grafonnet.panel.barChart.transformation.withId('filterFieldsByName')
        + grafonnet.panel.barChart.transformation.withOptions({
          include: {
            names: ['redpanda_topic', 'Value'],
          },
        }),
      ]),

      {},  // Line break

      // Active Connections
      common.timeseriesPanel(
        'Active Connections',
        [
          common.prometheusQuery(
            'sum by (listener) (redpanda_serverless_connections_active{redpanda_cloud_data_cluster_name=~"${data_cluster}"})',
            'Active Connections ({{listener}})'
          ),
        ],
        { fillOpacity: 0 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(7)
      + grafonnet.panel.timeSeries.gridPos.withH(6)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('none'),

      // New Connections Rate
      common.timeseriesPanel(
        'New Connections Rate',
        [
          common.prometheusQuery(
            'sum by (listener) (rate(redpanda_serverless_connections_created_total{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'New Connections Rate ({{listener}})'
          ),
        ],
        { fillOpacity: 0 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(8)
      + grafonnet.panel.timeSeries.gridPos.withH(6)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('reqps'),

      // Avg Connection Duration
      common.timeseriesPanel(
        'Avg Connection Duration',
        [
          common.prometheusQuery(
            'sum by (listener)(rate(redpanda_serverless_connections_duration_seconds_sum{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval])) / sum by (listener)(rate(redpanda_serverless_connections_duration_seconds_count{redpanda_cloud_data_cluster_name=~"${data_cluster}"}[$__rate_interval]))',
            'Avg Duration ({{listener}})'
          ),
        ],
        { fillOpacity: 20 }
      )
      + grafonnet.panel.timeSeries.gridPos.withW(9)
      + grafonnet.panel.timeSeries.gridPos.withH(6)
      + grafonnet.panel.timeSeries.standardOptions.withUnit('s')
      + grafonnet.panel.timeSeries.standardOptions.withDecimals(2),
  ],
}
