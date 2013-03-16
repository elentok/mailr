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

  getPasswordKeySuffix: (protocol) ->
    if @attribs[protocol]?.username?
      ":#{protocol}"
    else
      ''
  
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


Account.knownServices =
  Gmail:
    imap:
      host: 'imap.gmail.com'
      port: 993
