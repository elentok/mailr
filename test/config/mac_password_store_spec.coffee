require '../spec_helper'

commander = {}
keychainSync = {}

MacPasswordStore = sandbox.require '../../lib/config/mac_password_store',
  requires:
    'keychain-sync': keychainSync
    commander: commander

describe "MacPasswordStore", ->
  beforeEach ->
    @store = new MacPasswordStore()
    keychainSync.getPassword = sinon.stub()
    keychainSync.setPassword = sinon.stub()
    commander.password = sinon.stub()

  describe "#getPassword", ->
    describe "when the password is in the keychain", ->
      it "alls the callback with the password", ->
        callback = sinon.spy()
        keychainSync.getPassword.returns('the-password')
        @store.getPassword 'myAccount', callback
        expect(keychainSync.getPassword).to.have.been.calledWith('mailr', 'myAccount')
        expect(callback).to.have.been.calledWith(null, 'the-password')

    describe "when the password isn't in the keychain", ->
      it "asks the user for the password", ->
        keychainSync.getPassword.returns(null)
        commander.password.callsArgWith(1, 'the-password')

        callback = sinon.spy()
        @store.getPassword 'myAccount', callback
        expect(commander.password).to.have.been.called

      it "stores the password in the keychain", ->
        keychainSync.getPassword.returns(null)
        commander.password.callsArgWith(1, 'the-password')

        @store.getPassword 'myAccount', ->
        expect(keychainSync.setPassword).to.have.been.calledWith(
          'mailr', 'myAccount', 'the-password')

      it "calls the callback with the password", ->
        keychainSync.getPassword.returns(null)
        commander.password.callsArgWith(1, 'the-password')

        callback = sinon.spy()
        @store.getPassword 'myAccount', callback
        expect(callback).to.have.been.calledWith(null, 'the-password')
