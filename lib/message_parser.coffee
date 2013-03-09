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
    @message.text = @bodyLines.join("\n").trim()
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
      @_parseAddressesField('to', line)
    else if /^Cc:/.test(line)
      @state = 'in-field'
      @_parseAddressesField('cc', line)
    else if /^Bcc:/.test(line)
      @state = 'in-field'
      @_parseAddressesField('bcc', line)
    else if /^Subject:/.test(line)
      @state = 'in-field'
      @_parseSubject(line)
    else if /^==/.test(line)
      @state = 'in-body'

  _parseFrom: (line) ->
    @message.from = line.substring(5).trim()
    match = /<(.+)>/.exec(@message.from)
    if match?
      @message.fromAddress = match[1]
    else
      @message.fromAddress = @message.from

  _parseAddressesField: (fieldName, line) ->
    recipients = line.substring(fieldName.length + 1).trim().split(',')
    @message[fieldName] = _.map recipients, (recipient) -> recipient.trim()

  _parseSubject: (line) ->
    @message.subject = line.substring(8).trim()
