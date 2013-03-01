require '../spec_helper'

commander = {}
keychain = {}

MacPasswordStore = sandbox.require '../../lib/config/mac_password_store',
  requires:
    keychain: keychain
    commander: commander

describe "MacPasswordStore", ->
  beforeEach ->
    @store = new MacPasswordStore()
    keychain.getPassword = sinon.stub()
    keychain.setPassword = sinon.stub()
    commander.password = sinon.stub()

  describe "#getPassword", ->
    describe "when the password is in the keychain", ->
      it "calls the callback with the password", (done) ->
        keychain.getPassword.callsArgWith(1, null, 'the-password')

        @store.getPassword 'myAccount', (err, password) ->
          expectedOptions = { account: 'mailr', service: 'myAccount' }
          expect(keychain.getPassword.getCall(0).args[0]).to.eql expectedOptions
          expect(keychain.getPassword).to.have.been.calledWith(expectedOptions)
          expect(password).to.equal 'the-password'
          done()


    describe "when the password isn't in the keychain", ->
      it "asks the user for the password", (done) ->
        keychain.getPassword.callsArgWith(1, 'err', null)
        keychain.setPassword.callsArgWith(1, null)
        commander.password.callsArgWith(1, 'the-password')

        @store.getPassword 'myAccount', (err, password) ->
          expect(commander.password).to.have.been.called
          expect(password).to.equal 'the-password'
          done()

      it "stores the password in the keychain", (done) ->
        keychain.getPassword.callsArgWith(1, 'err', null)
        keychain.setPassword.callsArgWith(1, null)
        commander.password.callsArgWith(1, 'the-password')

        @store.getPassword 'myAccount', (err, password) ->
          expectedOptions =
            account: 'mailr'
            service: 'myAccount'
            password: 'the-password'
          expect(keychain.setPassword.getCall(0).args[0]).to.eql expectedOptions
          expect(keychain.setPassword).to.have.been.calledWith(expectedOptions)
          expect(commander.password).to.have.been.called
          expect(password).to.equal 'the-password'
          done()
