local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

// Import dashboard sections
local overview = import './serverless-overview.jsonnet';
local quota = import './serverless-quota.jsonnet';
local schemaRegistry = import './serverless-schema-registry.jsonnet';
local rpcn = import './serverless-rpcn.jsonnet';

local datasource = { type: 'prometheus', uid: '${DS_PROMETHEUS}' };

// Dashboard variables
local variables = [
  common.datasourceVariable(),
  common.dataClusterVariable(datasource),
];

// Build the complete panel list (flat structure with rows as separators)
// Concatenate all sections and apply auto-layout in one pass
local allPanels = common.layoutPanels(
  // Overview section
  [overview.row] + overview.panels(datasource) +
  // Quota section
  [quota.row] + quota.panels(datasource) +
  // Schema Registry section
  [schemaRegistry.row] + schemaRegistry.panels(datasource) +
  // Redpanda Connect section
  [rpcn.row] + rpcn.panels(datasource)
);

// Build the dashboard
grafonnet.dashboard.new('Redpanda Serverless Dashboard')
+ grafonnet.dashboard.withUid('redpanda-serverless')
+ grafonnet.dashboard.withTags([])
+ grafonnet.dashboard.withTimezone('')
+ grafonnet.dashboard.withEditable(true)
+ grafonnet.dashboard.withRefresh('5s')
+ grafonnet.dashboard.time.withFrom('now-15m')
+ grafonnet.dashboard.time.withTo('now')
+ grafonnet.dashboard.graphTooltip.withSharedCrosshair()
+ grafonnet.dashboard.withVariables(variables)
+ grafonnet.dashboard.withPanels(allPanels)
+ { __requires: common.dashboardRequirements() }
