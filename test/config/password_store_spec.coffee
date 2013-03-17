require '../spec_helper'

keychain =
  get: (key) ->
  set: (key, password) ->

commander =
  password: ->

store = sandbox.require '../../lib/config/password_store',
  requires:
    './mac_keychain': keychain
    commander: commander

describe "config/password_store", ->
  describe "#get(key)", ->
    it "returns a promise", ->
      expect(store.get('bla').then).to.be.a.function

    it "searches the keychain for the password", ->
      @stub(keychain, 'get').withArgs('mailr', 'the-key').returns('the-pass')
      store.get('the-key')
      keychain.get.should.have.been.calledWith 'mailr', 'the-key'

    describe "when the password is in the keychain", ->
      it "resolves with the password", (done) ->
        @stub(keychain, 'get').withArgs('mailr', 'the-key').returns('the-password')
        store.get('the-key').should.become('the-password').and.notify(done)

    describe "else", ->
      beforeEach ->
        @stub(keychain, 'get').withArgs('mailr', 'the-key').returns(null)
        @stub(commander, 'password')

      it "asks the user for a password", ->
        store.get('the-key')
        commander.password.should.have.been.called

      describe "when the user enters a password", ->
        beforeEach ->
          commander.password.callsArgWith(1, 'a-password')

        it "saves the password to the keychain", ->
          @stub(keychain, 'set')
          store.get('the-key')
          keychain.set.should.have.been.calledWith('mailr', 'the-key', 'a-password')

        it "resolves with the password", ->
          store.get('the-key').should.become('a-password')

      describe "when the user enters an empty password", ->
        it "fails with 'user-abort'", (done) ->
          commander.password.callsArgWith(1, '')
          store.get('the-key').should.be.rejected.with(Error, 'user-abort').and.notify(done)

      describe "when the user aborts", ->
        it "fails with 'user-abort'", (done) ->
          commander.password.callsArgWith(1, null)
          store.get('the-key').should.be.rejected.with(Error, 'user-abort').and.notify(done)

