passwordStore = require './password_store'
Q = require 'q'

module.exports = class Account
  constructor: (attribs = {}) ->
    @attribs = attribs

  getFromAddress: ->
    if @attribs.fullname?
      "#{@attribs.fullname} <#{@getEmail()}>"
    else
      @getEmail()

  getEmail: ->
    @attribs.email or @attribs.username

  getUsername: (protocol) ->
    if @attribs[protocol]?.username?
      @attribs[protocol].username
    else
      @attribs.username

  getPasswordKey: (protocol) ->
    if @attribs[protocol]?.username?
      "#{@attribs.name}:#{protocol}"
    else
      @attribs.name

  getPassword: (protocol) ->
    key = @getPasswordKey(protocol)
    Q.when(passwordStore.get(key))
  
  getService: -> @attribs.service

  getServer: (protocolName) ->
    protocol = @attribs[protocolName]
    if protocol?.host?
      server = { host: protocol.host }
      server.port = protocol.port if protocol?.port?
      return server
    else
      service = Account.knownServices[@getService()]
      if service?[protocolName]?
        return service[protocolName]

  getSmtpSettings: ->
    @getPassword('smtp') \
      .then (password) =>
        {
          service: @getService()
          auth:
            user: @getUsername()
            pass: password
        }

  getContactsSettings: ->
    @getPassword('contacts') \
      .then (password) =>
        {
          email: @getUsername()
          password: password
        }

Account.knownServices =
  Gmail:
    imap:
      host: 'imap.gmail.com'
      port: 993
