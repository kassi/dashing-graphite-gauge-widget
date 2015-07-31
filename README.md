## Description

[Dashing](http://shopify.github.io/dashing/) widget to show the current value of a
graphite gauge metric and a sparkline of the metric over certain number of days.

## Notes

This is a modified clone of https://github.com/edasque/dashing-graphite-text-widget.git

## Installation

- Download [Moment.js](http://momentjs.com/downloads/moment.min.js), [jquery.sparklines.js](http://omnipotent.net/jquery.sparkline/#s-about) and [lodash.min.js](https://raw.githubusercontent.com/lodash/lodash/2.4.1/dist/lodash.min.js) and place them in the `assets/javascripts` folder
- Finally create a dashboard and use the Gauge widget. Don't forget to set your title, graphite_host and metric:

```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
      <div data-view="Gauge" data-metric="stats.gauges.my.queue_entries.total"
      data-title="Queue Entries" data-graphite_host="http://my.graphite.host"data-unit="entries" data-colors="0:#96bf48,100:#ff9618,500:#d26771"></div>
</li>
```

## Configuration

There are several `data` attributes to configure the widget

| name | mandatory | description |
| ---- | --------- | ----------- |
| data-view | yes | Fix name of the widget view: Gauge |
| data-graphite_host | yes | URL to your graphite host |
| data-metric | yes | Metric of the graphite values in dot-notation |
| data-title | no | Title of the widget |
| data-colors | no | List of limit:color values for colouring the widget |
| data-unit | no | Text placed behind the number in the widget |

### Colouring

This attribute takes a comma separated list of limit:colour values.
To determine the background colour of the widget a gradient colour will be calculated that fits the current ghraphite value.

The example above will colourize a value of 0 with a light green, a value of 100 with orange and everything between 0 and 100 will be calculated as gradient between green and orange.
Each value above the upper limit given will be coloured in the last colour given.

The first entry should start with limit 0 (assuming that gauge values don't go below zero).

### Screen Shot

![Gauge Widget](http://www.kluks.de/uploads/files/dashing-graphite-gauge-widget.png)

## Authors

Based on [Erik Dasque's](https://github.com/edasque) graphite text widget

Adapted by Karsten Silkenbäumer

[![endorse](http://api.coderwall.com/ksi/endorsecount.png)](http://coderwall.com/ksi)
