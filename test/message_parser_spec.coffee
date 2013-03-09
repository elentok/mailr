require './spec_helper'

MessageParser = require '../lib/message_parser'

describe 'MessageParser', ->
  describe '#parse', ->
    it 'parses message1.email', ->
      parser = new MessageParser()
      message = parser.parse('test/fixtures/message1.email')
      expect(message).to.eql {
        from: 'Me <me@me.com>'
        fromAddress: 'me@me.com'
        to: ['You <you@you.com>', 'YouToo <you2@you.com>']
        cc: ['Bob <bob@you.com>']
        bcc: ['Joe <joe@you.com>']
        subject: 'Hello World!'
        text: "Hi!\nHow are you doing?\n\nThanks,\nMe."
      }
