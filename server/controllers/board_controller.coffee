Board = require '../models/board'
Post = require '../models/post'
Thread = require '../models/thread'

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
    if err
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
      console.log name
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
          
        res.redirect "/board/#{req.params.boardName}"
      
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
    return if not result? or not result.threads[0]?
    res.render 'board/viewThread',
      board: result,
      thread: result.threads[0]
      
boardController.postInThread = (req, res, next) ->
  return next() if not req.params.boardName? or not req.params.id?
  Board.findOne
    name: req.params.boardName
  , (err, result) ->
    # Fail if there is no board
    return next() if not result?
    Board.increasePostCount result._id, (err, result) ->
      if err? or not result?
        console.log err
        res.end 'There was an error!'
      console.log req.body.name
      name = if req.body.name? and String(req.body.name.length).length isnt 0 then req.body.name else 'Anonymous'
      currentPostCount = result.postCount
      post = new Post(
        id: currentPostCount
        name: name
        text: req.body.comment
      )
      Board.update
        name: req.params.boardName
        "threads.id": req.params.id
      ,
        $push:
          "threads.$.posts":
            post
      , (err, result) ->
        return next() if not result?
        res.redirect "/board/#{req.params.boardName}/thread/#{req.params.id}#p#{currentPostCount}"              
      
module.exports = boardController