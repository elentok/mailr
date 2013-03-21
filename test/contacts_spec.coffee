require './spec_helper'

fs =
  mkdirSync: ->
  existsSync: -> true
  writeFileSync: ->

config =
  currentPath: ''
  accounts:
    myAccount:
      getContactsSettings: -> Q.when('the-settings')


class GoogleContacts
  connect: -> Q.when(123)
  getContacts: -> Q.when(456)

contacts = sandbox.require '../lib/contacts',
  requires:
    './config/config': config
    gcontacts: GoogleContacts
    fs: fs

describe "lib/contacts", ->
  describe "#getContacts", ->
    it "returns a promise", ->
      contacts.getContacts('myAccount').then.should.be.a.function
    it "calls account.getContactsSettings", ->
      @stub(config.accounts.myAccount, 'getContactsSettings').returns(Q.when(123))
      contacts.getContacts('myAccount')
      expect(config.accounts.myAccount.getContactsSettings).to.have.been.called
    it "calls GoogleContacts::connect", (done) ->
      @stub(GoogleContacts.prototype, 'connect').returns(Q.when(123))
      contacts.getContacts('myAccount').then ->
        expect(GoogleContacts::connect).to.have.been.calledWith('the-settings')
        done()
    it "calls GoogleContacts::getContacts", (done) ->
      page = { contacts: 'the-contacts' }
      @stub(GoogleContacts.prototype, 'getContacts').returns(Q.when(page))
      contacts.getContacts('myAccount').should.become('the-contacts').and.notify(done)

  describe "#getContactsFile(accountName)", ->
    beforeEach ->
      config.currentPath = 'the-path'
    it "creates the path if it doesn't exist", ->
      @stub(fs, 'mkdirSync')
      @stub(fs, 'existsSync').withArgs('the-path/contacts').returns(false)
      contacts.getContactsFile('myAccount')
      fs.mkdirSync.should.have.been.calledWith('the-path/contacts')
    it "returns {config.currentPath}/contacts/{accountName}.contacts", ->
      contacts.getContactsFile('myAccount').should.equal \
        'the-path/contacts/myAccount.contacts'

  describe "#updateContacts(accountName)", ->
    beforeEach ->
      @stub(contacts, 'getContacts')

    it "calls getContacts", ->
      contacts.getContacts.returns(Q.when([]))
      contacts.updateContacts('bla')
      expect(contacts.getContacts).to.have.been.calledWith('bla')

    it "formats each contact using 'formatContact'", (done) ->
      @stub(contacts, 'formatContact')
      contact = {email: 'bob@gmail.com'}
      contacts.getContacts.returns(Q.when([contact]))
      contacts.updateContacts('bla').then ->
        contacts.formatContact.should.have.been.calledWith(contact)
        done()

    it "writes the contacts to file", (done) ->
      theContacts = [ { email: 'bob@gmail.com' }, { email: 'joe@gmail.com' } ]
      @stub(fs, 'writeFileSync')
      @stub(contacts, 'getContactsFile').withArgs('bla').returns('the-path')
      contacts.getContacts.returns(Q.when(theContacts))
      contacts.updateContacts('bla').then ->
        fs.writeFileSync.should.have.been.calledWith('the-path',
          'bob@gmail.com\njoe@gmail.com')
        done()

    it "resolves the promise when successful", (done) ->
      contacts.getContacts.returns(Q.when([]))
      contacts.updateContacts('bla').then ->
        done()

  describe "#formatContact", ->
    test_formatContact = (contact, output) ->
      describe "when contact is #{JSON.stringify(contact)}", ->
        it "returns '#{output}'", ->
          contacts.formatContact(contact).should.equal output

    test_formatContact { email: 'bob@gmail.com' }, 'bob@gmail.com'
    test_formatContact { email: 'bob@gmail.com', name: 'bob' }, 'bob <bob@gmail.com>'


