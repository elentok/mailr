fs = require 'fs'
_ = require 'lodash'

module.exports = class MessageParser
  parse: (filePath) ->
    email = fs.readFileSync(filePath, 'utf-8')
    @state = 'initial'
    @message = {}
    @bodyLines = []
    for line in email.split("\n")
      @_parseLine(line)
    @message.body = @bodyLines.join("\n").trim()
    @message

  _parseLine: (line) ->
    if @state == 'in-body'
      @bodyLines.push(line)
    else
      @_parseHeaderLine(line)

  _parseHeaderLine: (line) ->
    if /^From:/.test(line)
      @state = 'in-field'
      @_parseFrom(line)
    else if /^To:/.test(line)
      @state = 'in-field'
      @_parseTo(line)
    else if /^Subject:/.test(line)
      @state = 'in-field'
      @_parseSubject(line)
    else if /^==/.test(line)
      @state = 'in-body'

  _parseFrom: (line) ->
    @message.from = line.substring(5).trim()

  _parseTo: (line) ->
    recipients = line.substring(3).trim().split(',')
    @message.to = _.map recipients, (recipient) -> recipient.trim()

  _parseSubject: (line) ->
    @message.subject = line.substring(8).trim()
