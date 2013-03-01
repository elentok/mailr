path = require 'path'
fs = require 'fs'

defaultConfigDir = path.join(process.env['HOME'], '.mailr')

module.exports = class Config
  constructor: (@path = defaultConfigDir) ->
    @accounts = {}
  load: ->
    unless fs.existsSync(@path)
      fs.mkdirSync(@path)
    filePath = path.resolve(path.join(@path, 'config.coffee'))
    if fs.existsSync(filePath)
      data = require filePath
      for own key, value of data
        @[key] = value



