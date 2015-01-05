Board = require '../models/board'
Post = require '../models/post'
Thread = require '../models/thread'
escape = require 'escape-html'
markup = require '../lib/markup'
async = require 'async'

boardController = {}

boardController.index = (req, res) ->
  Board.find {}, (err, result) ->
    params =
      boards: result
    res.render 'board/index', params
      
boardController.new = (req, res) ->
  return next() if not req.body.boardName?
  board = new Board(
    name: req.body.boardName
  )
  board.save (err, result) ->
    if err?
      console.log err
      req.flash 'info', 'There was an error adding your board!'
      res.redirect "/board"
    else
      req.flash 'info', 'Successfully added board!'
      res.redirect "/board/#{req.body.boardName}"

boardController.view = (req, res, next) ->
  return next() if not req.params.boardName?
  Board.findOne
    name: req.params.boardName
  , (err, result) ->
    return next() if not result?
    res.render 'board/view', board: result
      
boardController.newThread = (req, res, next) ->
  # We atleast want to know the thread's comment and the board name
  return next() if not req.params.boardName?
  if not req.body.comment? or not String(req.body.comment).length
    req.flash 'info', 'Can not post without comment!'
    # FIXME: "Cannot set headers after they are set?"
    res.redirect "/board/#{req.params.boardName}"
  Board.findOne
    name: req.params.boardName
  , (err, result) ->  
    # Fail if there is no board
    return next() if not result?
    
    Board.increasePostCount result._id, (err, result) ->
      if err? or not result?
        console.log err
        res.end 'There was an error!'
      name = if req.body.name? and String(req.body).length isnt 0 then req.body.name else 'Anonymous'
      thread = new Thread(
        id: result.postCount
        posts:
          [
            id: result.postCount
            name: name
            text: req.body.comment
            isOp: true
          ]
      )

      async.series([
        ((next) ->
          console.log req.files
          if req.files? and req.files.file?
            file = req.files.file
            thread.posts[0].file = file.path
            console.log thread.posts[0]
          next()
        ),
        ((next) ->
          # Update the board
          Board.update
            _id: result._id
          ,
            $push:
              threads: thread
          , (err, result) ->
            if err? or not result?
              req.flash 'info', 'There was a error creating your thread'
              console.log err
            next()
        )
      ]
      , (err, result) ->
        res.redirect "/board/#{req.params.boardName}"
      )
      
boardController.viewThread = (req, res, next) ->
  return next() if not req.params.boardName? or not req.params.id?
  Board.findOne
    name: req.params.boardName
    "threads.id": req.params.id
  ,
    name: req.params.boardName
    threads:
      $elemMatch:
        id: req.params.id
  , (err, result) ->
    return next() if not result? or not result.threads[0]?
    
    # Add markup
    for post, index in result.threads[0].posts
      post.text = markup.parseMarkup req.params.boardName, req.params.id, post.text
      
    res.render 'board/viewThread',
      board: result,
      thread: result.threads[0]
      
boardController.postInThread = (req, res, next) ->
  return next() if not req.params.boardName? or not req.params.id? or not req.body.comment?
  Board.findOne
    name: req.params.boardName
  , (err, result) ->
    # Fail if there is no board
    return next() if not result?
    Board.increasePostCount result._id, (err, result) ->
      if err? or not result?
        console.log err
        res.end 'There was an error!'
      name = if req.body.name? and String(req.body.name.length).length isnt 0 then req.body.name else 'Anonymous'
      currentPostCount = result.postCount
      escapedText = escape(req.body.comment)
      post = new Post(
        id: currentPostCount
        name: name
        text: escapedText
      )

      async.series([
        ((_next) ->
          console.log req.files
          if req.files? and req.files.file?
            file = req.files.file
            post.file = file.path
            console.log post
          _next()
        ),
        ((_next) ->
          Board.update
            name: req.params.boardName
            "threads.id": req.params.id
          ,
            $push:
              "threads.$.posts":
                post
          , (err, result) ->
            return next() if not result?
            _next()
        )
      ]
      , (err, result) -> 
          res.redirect "/board/#{req.params.boardName}/thread/#{req.params.id}#p#{currentPostCount}"
      )
      
module.exports = boardController