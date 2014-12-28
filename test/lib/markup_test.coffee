markup = require '../../server/lib/markup'
should = require('chai').should()
_s = require 'underscore.string'

describe 'the markup lib', ->
  it 'should parse markup', ->
    boardName = "b"
    threadID = "3023"
    text = '&gt;&gt;3049 I hope you are not serious with that'
    body = markup.parseMarkup boardName, threadID, text
    console.log body
    _s.include(body, 'I hope you are not serious with that').should.be.true
    _s.include(body, '<a href="/board/b/thread/3023/#p3049">&gt;&gt;3049</a>').should.be.true
    
  it 'leave a text alone if does not have any markup', ->
    boardName = "b"
    threadID = "203"
    text = "Rate my gf /b/"
    body = markup.parseMarkup boardName, threadID, text
    (body == text).should.be.true