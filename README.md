## Description

[Dashing](http://shopify.github.io/dashing/) widget to show the current value of a
graphite gauge metric and a sparkline of the metric over certain number of days.

## Notes

This is a modified clone of https://github.com/edasque/dashing-graphite-text-widget.git

## Installation

- Download [Moment.js](http://momentjs.com/downloads/moment.min.js), [jquery.sparklines.js](http://omnipotent.net/jquery.sparkline/#s-about) and [lodash.min.js](https://raw.githubusercontent.com/lodash/lodash/2.4.1/dist/lodash.min.js) and place them in the `assets/javascripts` folder
- Finally create a dashboard and use the Timer widget. Dont' forget to set your timer, title & graphite_host:

```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
      <div data-view="Gauge" data-metric="stats.gauges.my.queue_entries.total"
      data-title="Queue Entries" data-graphite_host="http://my.graphite.host"
       data-unit="entries" data-colors="0:#96bf48,100:#ff9618,500:#d26771"></div>
</li>
```

