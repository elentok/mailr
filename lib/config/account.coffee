module.exports = class Account
  constructor: (attribs = {}) ->
    @attribs = attribs

  getAddress: ->
    if @attribs.fullname?
      "#{@attribs.fullname} <#{@getEmail()}>"
    else
      @getEmail()

  getEmail: ->
    @attribs.email or @attribs.username
