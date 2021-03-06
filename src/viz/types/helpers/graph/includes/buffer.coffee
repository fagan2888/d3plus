buckets = require "../../../../../util/buckets.coffee"
closest = require "../../../../../util/closest.coffee"

module.exports = (vars, axis, buffer) ->

  if vars[axis].scale.value isnt "share" and !vars[axis].range.value

    if axis is vars.axes.discrete

      domain = vars[axis].scale.viz.domain()

      if typeof domain[0] is "string"
        i = domain.length
        while i >= 0
          domain.splice(i, 0, "d3plus_buffer_"+i)
          i--
        range = vars[axis].scale.viz.range()
        range = buckets d3.extent(range), domain.length
        vars[axis].scale.viz.domain(domain).range(range)

      else

        domain = domain.slice().reverse() if axis is "y"

        if vars[axis].ticks.values.length is 1
          if vars[axis].value is vars.time.value and
             vars.data.time.ticks.length isnt 1
            closestTime = closest(vars.data.time.ticks, domain[0])
            timeIndex = vars.data.time.ticks.indexOf(closestTime)
            if timeIndex > 0
              domain[0] = vars.data.time.ticks[timeIndex - 1]
            else
              diff = vars.data.time.ticks[timeIndex + 1] - closestTime
              domain[0] = new Date(closestTime.getTime() - diff)
            if timeIndex < vars.data.time.ticks.length - 1
              domain[1] = vars.data.time.ticks[timeIndex + 1]
            else
              diff = closestTime - vars.data.time.ticks[timeIndex - 1]
              domain[1] = new Date(closestTime.getTime() + diff)
          else
            domain[0] -= 1
            domain[1] += 1
        else
          difference = Math.abs domain[1] - domain[0]
          additional = difference / (vars[axis].ticks.values.length - 1)
          additional = additional / 2

          domain[0] = domain[0] - additional
          domain[1] = domain[1] + additional

        domain = domain.reverse() if axis is "y"

        vars[axis].scale.viz.domain(domain)

    else if (buffer is "x" and axis is "x") or
            (buffer is "y" and axis is "y") or
            (buffer is true)

      domain = vars[axis].scale.viz.domain()

      allPositive = domain[0] >= 0 and domain[1] >= 0
      allNegative = domain[0] <= 0 and domain[1] <= 0

      if vars[axis].scale.value is "log"

        zero = if allPositive then 1 else -1
        domain = domain.slice().reverse() if allPositive and axis is "y"

        lowerScale = Math.pow(10, parseInt(Math.abs(domain[0])).toString().length - 1) * zero
        lowerMod = domain[0] % lowerScale
        lowerDiff = lowerMod
        if lowerMod and lowerDiff/lowerScale <= 0.1
          lowerDiff += lowerScale * zero
        lowerValue = if lowerMod is 0 then lowerScale else lowerDiff
        domain[0] -= lowerValue
        domain[0] = zero if domain[0] is 0

        upperScale = Math.pow(10, parseInt(Math.abs(domain[1])).toString().length - 1) * zero
        upperMod = domain[1] % upperScale
        upperDiff = Math.abs(upperScale - upperMod)
        if upperMod and upperDiff/upperScale <= 0.1
          upperDiff += upperScale * zero
        upperValue = if upperMod is 0 then upperScale else upperDiff
        domain[1] += upperValue
        domain[1] = zero if domain[1] is 0

        domain = domain.reverse() if allPositive and axis is "y"

      else
        zero = 0
        domain = domain.slice().reverse() if axis is "y"

        additional = Math.abs(domain[1] - domain[0]) * 0.05 or 1

        domain[0] = domain[0] - additional
        domain[1] = domain[1] + additional

        domain[0] = zero if (allPositive and domain[0] < zero) or
                            (allNegative and domain[0] > zero)
        domain[1] = zero if (allPositive and domain[1] < zero) or
                            (allNegative and domain[1] > zero)

        domain = domain.reverse() if axis is "y"

      vars[axis].scale.viz.domain(domain)

    else if vars.axes.scale

      rangeMax = vars[axis].scale.viz.range()[1]
      maxSize  = vars.axes.scale.range()[1]

      domainHigh = vars[axis].scale.viz.invert -maxSize * 2
      domainLow  = vars[axis].scale.viz.invert rangeMax + maxSize * 2
      difference = Math.abs domainHigh - domainLow

      if Math.round(domainHigh) is Math.round(domainLow)
        domainHigh -= difference/8
        domainLow  += difference/8

      vars[axis].scale.viz.domain([domainHigh,domainLow])
