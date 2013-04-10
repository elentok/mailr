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
        html: "<p>Hi!\nHow are you doing?</p>\n<p>Thanks,\nMe.</p>\n"
      }

    it 'parses message-markdown.email', ->
      parser = new MessageParser()
      message = parser.parse('test/fixtures/message-markdown.email')
      expect(message).to.eql {
        from: 'Me <me@me.com>'
        fromAddress: 'me@me.com'
        to: ['You <you@you.com>']
        subject: 'Hello World!'
        text: "# Chapter1\n## Chapter1.2\n\n# Chapter2\n\n" +
          "http://www.google.com\n\n[CNN](http://www.cnn.com)\n\nLine1\nLine2",
        html: "<h1>Chapter1</h1>\n" +
         "<h2>Chapter1.2</h2>\n" +
         "<h1>Chapter2</h1>\n" +
         "<p><a href=\"http://www.google.com\">" +
           "http://www.google.com</a></p>\n" +
         "<p><a href=\"http://www.cnn.com\">CNN</a></p>\n" +
         "<p>Line1\n" +
         "Line2</p>\n"
      }
