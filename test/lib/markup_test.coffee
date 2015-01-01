markup = require '../../server/lib/markup'
should = require('chai').should()
_s = require 'underscore.string'

describe 'the markup lib', ->
  it 'should parse markup', ->
    boardName = "b"
    threadID = "3023"
    text = '&gt;&gt;3049 I hope you are not serious with that'
    body = markup.parseMarkup boardName, threadID, text
    _s.include(body, 'I hope you are not serious with that').should.be.true
    _s.include(body, '<a href="/board/b/thread/3023/#p3049">&gt;&gt;3049</a>').should.be.true
    
  it 'should only parse cites with a number in it', ->
    boardName = "b"
    threadID = "3023"
    text = '&gt;&gt;yo yo'
    body = markup.parseMarkup boardName, threadID, text
    body.should.equal '&gt;&gt;yo yo'
    
  it 'leave a text alone if does not have any markup', ->
    boardName = "b"
    threadID = "203"
    text = "Rate my gf /b/"
    body = markup.parseMarkup boardName, threadID, text
    body.should.equal text
    
  it 'should convert newlines to <br> tags', ->
    boardName = "b"
    threadID = "666"
    text = "Yo\nCHECK EM"
    body = markup.parseMarkup boardName, threadID, text
    body.should.equal 'Yo<br>CHECK EM'
  
  it 'should parse greentext', ->
    boardName = "b"
    threadID = "777"
    text = "&gt;Not wanting putin to invade you"
    body = markup.parseMarkup boardName, threadID, text
    body.should.equal "<p class='greentext'>&gt;Not wanting putin to invade you</p>"
    
  it 'should remove unneeded newlines', ->
    boardName = "b"
    threadID = "777"
    text= 'lol\n\n\n\n\n\n\n\n\n\n\n\n\n'
    body = markup.parseMarkup boardName, threadID, text
    body.should.equal 'lol'