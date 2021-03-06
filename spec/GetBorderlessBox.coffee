noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetBorderlessBox = require '../components/GetBorderlessBox.coffee'
  testutils = require './testutils'
else
  GetBorderlessBox = require 'noflo-image/components/GetBorderlessBox.js'
  testutils = require 'noflo-image/spec/testutils.js'

checkSimilar = (chai, bbox, expected, delta) ->
  chai.expect(bbox.x).to.be.closeTo expected.x, delta
  chai.expect(bbox.y).to.be.closeTo expected.y, delta
  chai.expect(bbox.width).to.be.closeTo expected.width, delta
  chai.expect(bbox.height).to.be.closeTo expected.height, delta

describe 'GetBorderlessBox component', ->
  c = null
  canvas = null
  mean = null
  max = null
  avg = null
  out = null

  beforeEach ->
    c = GetBorderlessBox.getComponent()
    canvas = noflo.internalSocket.createSocket()
    mean = noflo.internalSocket.createSocket()
    max = noflo.internalSocket.createSocket()
    avg = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()

    c.inPorts.canvas.attach canvas
    c.inPorts.mean.attach mean
    c.inPorts.max.attach max
    c.inPorts.avg.attach avg
    c.outPorts.rectangle.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
      chai.expect(c.inPorts.mean).to.be.an 'object'
      chai.expect(c.inPorts.max).to.be.an 'object'
      chai.expect(c.inPorts.avg).to.be.an 'object'
    it 'should have output ports', ->
      chai.expect(c.outPorts.rectangle).to.be.an 'object'

  describe 'when passed a canvas', ->
    it 'should remove left and right white borders', (done) ->
      @timeout 10000
      groupId = 'rectangle-ranges'
      groups = []
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.be.eql ['rectangle-ranges']
        expected =
          x: 38
          y: 0
          width: 522
          height: 338
        checkSimilar chai, res, expected, 3
        done()

      inSrc = 'borderless1.jpg'
      testutils.getCanvasWithImageNoShift inSrc, (c) ->
        canvas.beginGroup groupId
        mean.send 0.5
        max.send 10
        avg.send 10
        canvas.send c
        canvas.endGroup()

    it 'should remove left and right black borders', (done) ->
      @timeout 10000
      groupId = 'rectangle-ranges'
      groups = []
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.be.eql ['rectangle-ranges']
        expected =
          x: 64
          y: 0
          width: 1152
          height: 720
        checkSimilar chai, res, expected, 3
        done()

      inSrc = 'borderless2.jpg'
      testutils.getCanvasWithImageNoShift inSrc, (c) ->
        canvas.beginGroup groupId
        canvas.send c
        canvas.endGroup()

    it 'should remove up and down black borders', (done) ->
      @timeout 10000
      groupId = 'rectangle-ranges'
      groups = []
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.be.eql ['rectangle-ranges']
        expected =
          x: 0
          y: 48
          width: 480
          height: 264
        checkSimilar chai, res, expected, 3
        done()

      inSrc = 'borderless3.jpg'
      testutils.getCanvasWithImageNoShift inSrc, (c) ->
        canvas.beginGroup groupId
        canvas.send c
        canvas.endGroup()

    it 'should remove up and down white borders', (done) ->
      @timeout 10000
      groupId = 'rectangle-ranges'
      groups = []
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.be.eql ['rectangle-ranges']
        expected =
          x: 0
          y: 106
          width: 640
          height: 430
        checkSimilar chai, res, expected, 3
        done()

      inSrc = 'borderless4.jpg'
      testutils.getCanvasWithImageNoShift inSrc, (c) ->
        canvas.beginGroup groupId
        canvas.send c
        canvas.endGroup()

    it 'should not remove borders', (done) ->
      @timeout 10000
      groupId = 'rectangle-ranges'
      groups = []
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.be.eql ['rectangle-ranges']
        expected =
          x: 0
          y: 0
          width: 80
          height: 80
        checkSimilar chai, res, expected, 3
        done()

      inSrc = 'original.jpg'
      testutils.getCanvasWithImageNoShift inSrc, (c) ->
        canvas.beginGroup groupId
        mean.send 0.5
        max.send 10
        avg.send 10
        canvas.send c
        canvas.endGroup()
