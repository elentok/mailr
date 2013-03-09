require '../spec_helper'
Account = require '../../lib/config/account'

test = (methodName, attributes, output) ->
  describe "when #{JSON.stringify(attributes)}", ->
    it "returns '#{output}'", ->
      account = new Account(attributes)
      expect(account[methodName]()).to.equal output

testWithArgs = (methodName, args, attributes, output) ->
  argsJSON = JSON.stringify(args)
  describe "(#{argsJSON}) when #{JSON.stringify(attributes)}", ->
    it "returns '#{output}'", ->
      account = new Account(attributes)
      expect(account[methodName].apply(account, args)).to.equal output

describe "Account", ->

  describe "#getFromAddress", ->
    test 'getFromAddress', { username: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getFromAddress', { email: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getFromAddress', { email: 'email', username: 'user' }, 'email'
    test 'getFromAddress', { email: 'bob@gmail.com', fullname: 'Bob' }, 'Bob <bob@gmail.com>'

  describe "#getEmail", ->
    test 'getEmail', { username: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getEmail', { email: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getEmail', { email: 'bob@gmail.com', username: '123' }, 'bob@gmail.com'

  describe "#getUsername(protocol)", ->
    test 'getUsername', { username: 'bob' }, 'bob'
    testWithArgs 'getUsername', ['smtp'], { username: 'bob' }, 'bob'
    testWithArgs 'getUsername', ['smtp'], { smtp: { username: 'bob' } }, 'bob'

  describe "#getPasswordKeySuffix(protocol)", ->
    testWithArgs 'getPasswordKeySuffix', ['smtp'], { username: 'bob' }, ''
    testWithArgs 'getPasswordKeySuffix', ['smtp'], { smtp: { username: 'bob' } }, ':smtp'

  describe "#getService", ->
    test 'getService', { service: '123' }, '123'
