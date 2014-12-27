_s = require 'underscore.string'
Browser = require 'zombie'
should = require('chai').should()
request = require 'request'
qs = require 'querystring'

APP_ROOT = 'http://localhost:5000'

describe 'the board controller', ->
  before (done) ->
    Browser.localhost APP_ROOT
    require('../../server/models/board').remove {}, (err, result) ->
      done()
    
  it 'should respond with 200 at index', (done) ->
    request.get "#{APP_ROOT}/board", (error, response, body) ->
      response.statusCode.should.equal 200
      done()
      
  it 'should create a new board', (done) ->
    browser = Browser.create()
    browser.visit '/board', (error) ->
      should.not.exist(error)
      browser.fill 'input[name="boardName"]', 'MySpecialBoard'
      browser.pressButton 'Create', () ->
        browser.success.should.be.ok
        _s.include(browser.html(), 'MySpecialBoard').should.be.true;
        _s.include(browser.html(), 'Successfully added board!').should.be.true;
        _s.include(browser.html(), 'There was an error adding your board!').should.be.false;
        done()
        
  it 'should not create a board twice', (done) ->
    browser = Browser.create()
    browser.visit '/board', (error) ->
      should.not.exist(error)
      browser.fill 'input[name="boardName"]', 'MySpecialBoard'
      browser.pressButton 'Create', () ->
        browser.success.should.be.ok
        _s.include(browser.html(), 'MySpecialBoard').should.be.true;
        _s.include(browser.html(), 'Successfully added board!').should.be.false;
        _s.include(browser.html(), 'There was an error adding your board!').should.be.true;
        done()
        
  it 'should be able to visit the board', (done) ->
    browser = Browser.create()
    browser.visit '/board/MySpecialBoard', (error) ->
      should.not.exist(error)
      browser.success.should.be.ok
      _s.include(browser.html(), 'Fail').should.be.false;
      _s.include(browser.html(), 'MySpecialBoard').should.be.true;
      done()
      
  it 'should not be able to visit a board that does not exist', (done) ->
    browser = Browser.create()
    browser.visit '/board/asdasd', (error) ->
      error.should.be.ok
      done()
      
  it 'should create a thread', (done) ->
    browser = Browser.create()
    browser.visit '/board/MySpecialBoard', (error) ->
      should.not.exist(error)
      browser.fill 'textarea[name="comment"]', 'This is a thread!'
      browser.pressButton 'Create Thread', () ->
        browser.success.should.be.ok
        _s.include(browser.html(), 'This is a thread!').should.be.true;
        done()
        
  it 'should open a thread', (done) ->
    browser = Browser.create()
    browser.visit '/board/MySpecialBoard/thread/1', (error) ->
      should.not.exist(error)
      _s.include(browser.html(), 'This is a thread!').should.be.true;
      done()
      
  it 'should post in a thread', (done) ->
    browser = Browser.create()
    browser.visit '/board/MySpecialBoard/thread/1', (error) ->
      should.not.exist(error)
      browser.fill 'textarea[name="comment"]', 'Posting!'
      browser.pressButton 'Post', () ->
        browser.success.should.be.ok
        _s.include(browser.html(), 'Posting!').should.be.true
        done()