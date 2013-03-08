require '../spec_helper'
Account = require '../../lib/config/account'

test_getAddress = (attributes, output) ->
  describe "with #{JSON.stringify(attributes)}", ->
    it "returns '#{output}'", ->
      account = new Account(attributes)
      expect(account.getAddress()).to.equal output

test_getEmail = (attributes, output) ->
  describe "with #{JSON.stringify(attributes)}", ->
    it "returns '#{output}'", ->
      account = new Account(attributes)
      expect(account.getEmail()).to.equal output

describe "Account", ->

  describe "#getAddress", ->
    test_getAddress { username: 'bob@gmail.com' }, 'bob@gmail.com'
    test_getAddress { email: 'bob@gmail.com' }, 'bob@gmail.com'
    test_getAddress { email: 'email', username: 'user' }, 'email'
    test_getAddress { email: 'bob@gmail.com', fullname: 'Bob' }, 'Bob <bob@gmail.com>'

  describe "#getEmail", ->
    test_getEmail { username: 'bob@gmail.com' }, 'bob@gmail.com'
    test_getEmail { email: 'bob@gmail.com' }, 'bob@gmail.com'
    test_getEmail { email: 'bob@gmail.com', username: '123' }, 'bob@gmail.com'
