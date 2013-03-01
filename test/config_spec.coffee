require './spec_helper'
Config = require '../lib/config'
fs = require 'fs'

tmpDir = '.mailr-config-test'

describe "Config", ->
  describe "#load", ->
    describe "when the config dir doesn't exist", ->
      beforeEach ->
        fs.rmdirSync(tmpDir) if fs.existsSync(tmpDir)
      afterEach ->
        fs.rmdirSync(tmpDir) if fs.existsSync(tmpDir)

      it "creates it", ->
        config = new Config(tmpDir)
        config.load()
        exists = fs.existsSync(tmpDir)
        expect(exists).to.be.true
        if exists
          isDir = fs.statSync(tmpDir).isDirectory()
          expect(isDir).to.be.true

      it "loads the accounts from 'config.coffee'", ->
        config = new Config('test/fixtures/config-dir')
        config.load()
        expect(config.accounts).to.eql {
          gmail:
            username: 'my-username'
            smtp:
              server: 'smtp.gmail.com'
              port: 465
            imap:
              server: 'imap.gmail.com'
              port: 993
        }
