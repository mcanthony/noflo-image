noflo = require 'noflo'
chroma = require 'chroma-js'

# @runtime noflo-nodejs

zero = (a) ->
  for i in [0...a.length]
    a[i] = 0
  return a

normalize = (a, max) ->
  for i in [0...a.length]
    a[i] = (a[i]/max)
  return a

# Perceptual brightness
# CIE Y'601. Input: sR'G'B' (gamma) [0.0-1.0]
cie_y601 = (r, g, b) ->
  return 0.299*r + 0.587*g + 0.114*b

computeHistogram = (canvas) ->
  res =
    r: zero new Array 256
    g: zero new Array 256
    b: zero new Array 256
    y: zero new Array 256
    h: zero new Array 361 # degrees [0,0, 360.0] -> [0, 361]
    s: zero new Array 101 # [0.0, 1.0] -> [0, 101]
    c: zero new Array 101 # ?
    l: zero new Array 101 # [0.0, 1.0] -> [0, 101]

  # TODO: check if individual scanlines is faster
  ctx = canvas.getContext '2d'
  imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
  data = imageData.data
  for i in [0...data.length] by 4
    [r, g, b] = [data[i], data[i+1], data[i+2]]
    y = cie_y601 r/255, g/255, b/255
    y = Math.floor y*255
    res.r[r]+=1
    res.g[g]+=1
    res.b[b]+=1
    res.y[y]+=1

    rgb = chroma(r, g, b, 'rgb')
    # CIE LCH (or popular HCL) and HSL
    lch = rgb.lch()
    hsl = rgb.hsl()
    h = Math.round hsl[0]
    s = hsl[1]*100|0
    l = hsl[2]*100|0
    c = Math.round lch[1]
    res.h[h] += 1
    res.s[s] += 1
    res.l[l] += 1
    res.c[c] += 1
  # Normalize such that 1.0 means all pixels have this color
  pixels = data.length/4
  normalize res.r, pixels
  normalize res.g, pixels
  normalize res.b, pixels
  normalize res.y, pixels
  normalize res.h, pixels
  normalize res.s, pixels
  normalize res.l, pixels
  normalize res.c, pixels

  return res

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'file-image-o'
  c.description = 'Calculate RGBY and HSCL histograms of a given canvas.'

  c.outPorts.add 'histogram',
    datatype: 'object'

  c.inPorts.add 'canvas',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: ['canvas']
    out: ['histogram']
    forwardGroups: true
    async: true
  , (payload, groups, out, callback) ->
    canvas = payload
    out.send computeHistogram canvas
    do callback

  c
