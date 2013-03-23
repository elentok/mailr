chai = require 'chai'
chai.should()
chai.use require('sinon-chai')
chai.use require('chai-as-promised')

require('mocha-as-promised')()

global.expect = chai.expect
global.sinon = require 'sinon'
global.sandbox = require 'sandboxed-module'
global.Q = require 'q'

beforeEach ->
  @sandbox = sinon.sandbox.create(
    injectInto: this,
    properties: ['spy', 'stub'])

afterEach ->
  @sandbox.restore()
