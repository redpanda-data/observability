// Common utilities and helpers for dashboards
local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  // Dashboard requirements (Grafana version and panel types)
  dashboardRequirements():: [
    {
      type: 'panel',
      id: 'barchart',
      name: 'Bar chart',
      version: '',
    },
    {
      type: 'panel',
      id: 'gauge',
      name: 'Gauge',
      version: '',
    },
    {
      type: 'grafana',
      id: 'grafana',
      name: 'Grafana',
      version: '9.3.6',
    },
    {
      type: 'datasource',
      id: 'prometheus',
      name: 'Prometheus',
      version: '1.0.0',
    },
    {
      type: 'panel',
      id: 'stat',
      name: 'Stat',
      version: '',
    },
    {
      type: 'panel',
      id: 'timeseries',
      name: 'Time series',
      version: '',
    },
  ],

  // Common datasource variable for Prometheus
  datasourceVariable()::
    grafonnet.dashboard.variable.datasource.new('DS_PROMETHEUS', 'prometheus')
    + grafonnet.dashboard.variable.datasource.generalOptions.withLabel('Data Source'),

  // Common data cluster variable
  dataClusterVariable(datasource)::
    grafonnet.dashboard.variable.query.new('data_cluster')
    + grafonnet.dashboard.variable.query.withDatasource(datasource.type, datasource.uid)
    + grafonnet.dashboard.variable.query.queryTypes.withLabelValues('redpanda_cloud_data_cluster_name')
    + grafonnet.dashboard.variable.query.generalOptions.withLabel('Data cluster')
    + grafonnet.dashboard.variable.query.selectionOptions.withMulti(true)
    + grafonnet.dashboard.variable.query.refresh.onLoad(),

  // Create a timeseries panel with common settings
  timeseriesPanel(title, targets, options={})::
    local defaults = {
      transparent: true,
      fillOpacity: 27,
      lineWidth: 1,
      showPoints: 'auto',
      legendDisplayMode: 'list',
      legendPlacement: 'bottom',
      tooltipMode: 'single',
    };
    local settings = defaults + options;

    grafonnet.panel.timeSeries.new(title)
    + grafonnet.panel.timeSeries.queryOptions.withTargets(targets)
    + grafonnet.panel.timeSeries.options.legend.withDisplayMode(settings.legendDisplayMode)
    + grafonnet.panel.timeSeries.options.legend.withPlacement(settings.legendPlacement)
    + grafonnet.panel.timeSeries.options.legend.withShowLegend(true)
    + grafonnet.panel.timeSeries.options.tooltip.withMode(settings.tooltipMode)
    + grafonnet.panel.timeSeries.standardOptions.withMin(0)
    + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(settings.fillOpacity)
    + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withLineWidth(settings.lineWidth)
    + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withShowPoints(settings.showPoints)
    + grafonnet.panel.timeSeries.panelOptions.withTransparent(settings.transparent),

  // Create a stat panel with common settings
  statPanel(title, targets, options={})::
    local defaults = {
      transparent: true,
      colorMode: 'value',
      graphMode: 'area',
      textMode: 'auto',
    };
    local settings = defaults + options;

    grafonnet.panel.stat.new(title)
    + grafonnet.panel.stat.queryOptions.withTargets(targets)
    + grafonnet.panel.stat.options.withColorMode(settings.colorMode)
    + grafonnet.panel.stat.options.withGraphMode(settings.graphMode)
    + grafonnet.panel.stat.options.withTextMode(settings.textMode)
    + grafonnet.panel.stat.options.reduceOptions.withCalcs(['lastNotNull'])
    + grafonnet.panel.stat.standardOptions.withMin(0)
    + grafonnet.panel.stat.panelOptions.withTransparent(settings.transparent),

  // Create a gauge panel with common settings
  gaugePanel(title, targets, options={})::
    local defaults = {
      transparent: true,
      min: 0,
      thresholds: [
        { color: 'green', value: 0 },
        { color: 'yellow', value: 75 },
        { color: 'red', value: 90 },
      ],
      unit: 'percent',
      decimals: 2,
    };
    local settings = defaults + options;

    grafonnet.panel.gauge.new(title)
    + grafonnet.panel.gauge.queryOptions.withTargets(targets)
    + grafonnet.panel.gauge.options.reduceOptions.withCalcs(['lastNotNull'])
    + grafonnet.panel.gauge.options.withShowThresholdLabels(false)
    + grafonnet.panel.gauge.options.withShowThresholdMarkers(true)
    + grafonnet.panel.gauge.standardOptions.withMin(settings.min)
    + grafonnet.panel.gauge.standardOptions.withUnit(settings.unit)
    + grafonnet.panel.gauge.standardOptions.withDecimals(settings.decimals)
    + grafonnet.panel.gauge.standardOptions.thresholds.withMode('absolute')
    + grafonnet.panel.gauge.standardOptions.thresholds.withSteps(settings.thresholds)
    + grafonnet.panel.gauge.panelOptions.withTransparent(settings.transparent),

  // Create a bar chart panel
  barChartPanel(title, targets, options={})::
    local defaults = {
      transparent: true,
      orientation: 'horizontal',
      showLegend: false,
    };
    local settings = defaults + options;

    grafonnet.panel.barChart.new(title)
    + grafonnet.panel.barChart.queryOptions.withTargets(targets)
    + grafonnet.panel.barChart.options.withOrientation(settings.orientation)
    + grafonnet.panel.barChart.options.legend.withShowLegend(settings.showLegend)
    + grafonnet.panel.barChart.options.legend.withPlacement('bottom')
    + grafonnet.panel.barChart.standardOptions.withMin(0)
    + grafonnet.panel.barChart.panelOptions.withTransparent(settings.transparent),

  // Helper to create Prometheus query target
  prometheusQuery(expr, legendFormat='__auto', options={})::
    local defaults = {
      datasource: { type: 'prometheus', uid: '${DS_PROMETHEUS}' },
      editorMode: 'code',
      range: true,
      instant: false,
      exemplar: true,
      format: null,
    };
    local settings = defaults + options;

    grafonnet.query.prometheus.new(settings.datasource.uid, expr)
    + grafonnet.query.prometheus.withLegendFormat(legendFormat)
    + grafonnet.query.prometheus.withEditorMode(settings.editorMode)
    + grafonnet.query.prometheus.withRange(settings.range)
    + grafonnet.query.prometheus.withInstant(settings.instant)
    + grafonnet.query.prometheus.withExemplar(settings.exemplar)
    + (if settings.format != null then { format: settings.format } else {}),

  // Create an HTML section header panel
  sectionHeaderPanel(title, options={})::
    local defaults = {
      color: '#87CEEB',
      x: 0,
      y: 0,
      w: 24,
      h: 2,
    };
    local settings = defaults + options;
    local htmlContent = '<h1 style="color:%(color)s; border-bottom: 3px solid %(color)s;">%(title)s</h1>' % { color: settings.color, title: title };

    grafonnet.panel.text.new('')
    + grafonnet.panel.text.options.withContent(htmlContent)
    + grafonnet.panel.text.options.withMode('html')
    + grafonnet.panel.text.panelOptions.withTransparent(true)
    + grafonnet.panel.text.gridPos.withX(settings.x)
    + grafonnet.panel.text.gridPos.withY(settings.y)
    + grafonnet.panel.text.gridPos.withW(settings.w)
    + grafonnet.panel.text.gridPos.withH(settings.h)
    + { datasource: { type: 'datasource', uid: 'grafana' } },

  // Auto-layout utilities
  local allMax = function(arr, def) std.foldl(std.max, arr, def),

  local getPos = function(parent, child)
    local
      cX0 = child.gridPos.w + parent.__nextX,
      mustWrap = cX0 > 24,
      combinedHeight = allMax(std.map(function(p) p.gridPos.y + p.gridPos.h, parent.panels), 0),
      cX = if mustWrap then 0 else parent.__nextX,
      cY = if mustWrap then combinedHeight else parent.__nextY,
      nX = cX + child.gridPos.w,
      nY = cY;
    { cX: cX, cY: cY, nX: nX, nY: nY },

  local addPanel = function(parent, child)
    if child == {}
    then
      local
        nextY = getPos(parent, { gridPos: { w: 24 } }).nY;
      // Wrap to next line without creating spacer panels
      parent {
        __nextX: 0,
        __nextY: nextY,
      }
    else
      local
        coords = getPos(parent, child),
        child1 = child { gridPos+: { x: coords.cX, y: coords.cY } };
      parent {
        __nextX: coords.nX,
        __nextY: coords.nY,
        panels+: [child1],
      },

  // Layout panels automatically starting from yOffset
  layoutPanels(panels, yOffset=0)::
    local
      initialState = {
        __nextX: 0,
        __nextY: yOffset,
        panels: [],
      },
      finalState = std.foldl(addPanel, panels, initialState);
    finalState.panels,
}
