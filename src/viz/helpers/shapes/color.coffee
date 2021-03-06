fetchValue = require "../../../core/fetch/value.coffee"
fetchColor = require "../../../core/fetch/color.coffee"
lighter    = require "../../../color/lighter.coffee"

# Returns the correct fill color for a node
module.exports = (d, vars, stroke) ->

  shape = d.d3plus.shape or vars.shape.value

  if vars.shape.value is "line" and shape isnt "circle"
    return "none"
  else if vars.shape.value is "area" or
          shape is "active" or
          vars.shape.value is "line"
    return fetchColor(vars, d)
  else if shape is "temp"
    if stroke
      return fetchColor(vars, d)
    else
      return "url(#d3plus_hatch_" + d.d3plus.id + ")"
  else if d.d3plus.static
    return lighter fetchColor(vars, d), .75

  active = vars.active.value
  active = if active then fetchValue(vars, d, active) else d.d3plus.active
  temp   = vars.temp.value
  temp   = if temp then fetchValue(vars, d, temp) else d.d3plus.temp
  total  = vars.total.value
  total  = if total then fetchValue(vars, d, total) else d.d3plus.total

  if (not vars.active.value and not vars.temp.value) or active is true or
     (active and total and active >= total and not temp) or
     (active and not total)
    fetchColor vars, d
  else if vars.active.spotlight.value
    "#eee"
  else
    lighter fetchColor(vars, d), .75
