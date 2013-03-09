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
