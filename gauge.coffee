class Dashing.Gauge extends Dashing.Widget

  displayError:(msg) ->
    $(@node).find(".error").show()
    $(@node).find(".error").html(msg)
  displayMissingDependency:(name,url) ->
    error_html = "<h1>Missing #{name}</h1><p>Download <a href='#{url}'>#{name}</a> and place it in the <span class='highlighted'>assets/javascripts</span> folder"
    @displayError(error_html)

  ready: ->

    @displayMissingDependency("moment.js","http://momentjs.com/downloads/moment.min.js") if (!window.moment)
    @displayMissingDependency("lodash.js","https://raw.githubusercontent.com/lodash/lodash/2.4.1/dist/lodash.min.js") if (!window._)
    @displayMissingDependency("jQuery Sparkline","http://omnipotent.net/jquery.sparkline/#s-about") if (!$.fn.sparkline)

    if @get('debug')
      @debug = (@get('debug'))
    else
      @debug = false

    # use the data-from property in the widget tag to indicate the time range (Default: 7d)
    if typeof @get('from') isnt "undefined"
      @from = (@get('from'))
    else
      @from = "7d"

    # use the data-unit property in the widget tag to indicate the unit to display (Default:ms)
    if typeof @get('unit') isnt "undefined"
      @unit = (@get('unit'))
    else
      @unit = "ms"

    # use the graphite_host property in the widget tag to indicate the graphite host (Default:our P2 graphite host)
    if @get('graphite_host')
      @graphite_host = (@get('graphite_host'))
    else
      @graphite_host = "http://graphite"

    $n = $(@node)

    # The widget looks at 24 hours worth of data in 10 minutes increment and compares it to the same day a week ago
    targets = ["#{@get('metric')}"]
    if @timeshift = (@get('timeshift'))
      targets.push "timeShift(#{@get('metric')}, '#{@get('timeshift')}')"

    @encoded_target = _.reduce(targets, (memo,target,key) ->
      memo += "&target=#{target}"
    ,"")

    if @get('interval')
      interval = parseInt(@get('interval'))
    else
      interval = 60000

    self = this

    console.dir self if @debug

    setInterval ->
      self.updateGraph()
    , interval
    @updateGraph()

    setInterval ->
      self.updateSparkline()
    , interval*100

    @updateSparkline()

  updateGraph: ->

    graph_data_url = "#{@graphite_host}/render?format=json#{@encoded_target}"
    console.log graph_data_url if @debug
    $.getJSON graph_data_url,
      from: '-' + @from
      until: '-6min',
      renderResults.bind(@)

  updateSparkline: ->
    metric = @get('metric')
    target = "&target=#{metric}"
    graph_data_url = "#{@graphite_host}/render?format=json#{target}"

    $.getJSON graph_data_url,
      from: '-' + @from
      until: '-6min',
      renderSparkline.bind(@)

  renderSparkline = (data) ->
    console.dir(data) if @debug
    dataset = removeTimestampFromTuple(data[0].datapoints)

    if dataset.length>1
      $(@node).find(".sparkline-chart").sparkline(dataset, {
        type: 'line',
        chartRangeMin: 0,
        drawNormalOnTop: true,
        normalRangeMax: 3000,
        width:'10em',
        normalRangeColor: '#336699'})
      $(@node).find(".sparkline-label").text("#{@from} ")
    else
      $(@node).find(".sparkline").hide()

  renderResults = (data) ->
    console.log data if @debug
    dataLatest = 0
    for point in data[0].datapoints.reverse()
      unless point[0] == null
        dataLatest = point[0]
        break

    change_rate = 0

    $(@node).find(".change-rate i").removeClass("icon-arrow-up").removeClass("icon-arrow-down")

    if isNaN change_rate
      change_rate = ""
      $(@node).find(".change-rate").css("font-size","1em")
      $(@node).find(".change-rate").css("line-height","40px")

    else if change_rate>0
      $(@node).find(".change-rate").css("color","red")
      change_rate=change_rate+"%"
      $(@node).find(".change-rate i").addClass("icon-arrow-up")

    else if change_rate==0
      $(@node).find(".change-rate").css("color","white")
      change_rate=""
      # change_rate="no change"
      $(@node).find(".change-rate").css("font-size","1em")
      $(@node).find(".change-rate").css("line-height","40px")
    else
      $(@node).find(".change-rate").css("color","green")
      change_rate=change_rate+"%"
      $(@node).find(".change-rate i").addClass("icon-arrow-down")

    unit = @unit
    if isNaN dataLatest
      $(@node).find(".value").text("N/A").fadeOut().fadeIn()
    else
      value = dataLatest.toLocaleString()
      sizeClass = getSizeClassForValue(value)
      $(@node).find(".value").html("#{value}<span style='font-size:.3em;'>#{unit}</span>").fadeOut().fadeIn()
      colors = _.map(@get('colors').split(","), (elem) -> elem.split(":"))
      color = getColorFromValue(colors, dataLatest)
      $(@node).fadeOut().css('background-color', color).fadeIn()
      $(@node).find(".value").addClass(sizeClass)

    $(@node).find(".change-rate span").text("#{change_rate}")
    $(@node).find(".change-rate span").fadeOut().fadeIn()
    $(@node).find(".updated-at").text(moment().format('MMMM Do YYYY, h:mmA')).fadeOut().fadeIn()

    return

  findLargestIndexSmallerThanValue = (arr, val) ->
    _.findLastIndex(arr, (elem) -> elem[0] <= val)

  getColorFromValue = (colors, val) ->
    index = findLargestIndexSmallerThanValue(colors, val)
    if colors.length == index + 1
      getColorFromTupel(colors[index])
    else
      color1 = getColorFromTupel(colors[index])
      color2 = getColorFromTupel(colors[index+1])
      value1 = getValueFromTupel(colors[index])
      value2 = getValueFromTupel(colors[index+1])
      ratio = (val - value1) / (value2 - value1)
      getGradientColor(color1, color2, ratio)

  getSizeClassForValue = (val) ->
    "length#{val.length}"

  hex = (x) ->
    y = x.toString(16)
    y.length == 1 ? '0' + y : y

  h = (x) ->
    ('0' + x.toString(16)).substr(-2)

  getGradientColor = (color1, color2, ratio) ->
    r = Math.ceil(parseInt(color1.substr(1,2), 16) * (1-ratio) + parseInt(color2.substr(1,2), 16) * ratio)
    g = Math.ceil(parseInt(color1.substr(3,2), 16) * (1-ratio) + parseInt(color2.substr(3,2), 16) * ratio)
    b = Math.ceil(parseInt(color1.substr(5,2), 16) * (1-ratio) + parseInt(color2.substr(5,2), 16) * ratio)
    "#" + h(r) + h(g) + h(b)

  getColorFromTupel = (arr) ->
    arr[1]
  getValueFromTupel = (arr) ->
    parseInt(arr[0],10)
  removeTimestampFromTuple = (arr) ->
    _.map(arr, (num) -> num[0])
  roundUpArrayValues = (arr) ->
    _.map(arr, (num) -> Math.floor(num))

  array_values_average = (arr) ->
    _.reduce(arr, (memo, num) ->
      memo + num
    , 0) / arr.length

