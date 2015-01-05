bodyParser = require 'body-parser'
express = require 'express'
flash = require 'express-flash'
passport = require 'passport'
mongoose = require 'mongoose'
multer = require 'multer'
session = require 'express-session'

ASSET_BUILD_PATH = 'server/client_build/development'
PORT = process.env.PORT ? 3000
MONGO_URL = process.env.MONGO_URL ? "mongodb://localhost/nchan"
SESSION_SECRET = process.env.SESSION_SECRET ? 'keyboard kitty'
WHITELISTED_URLS = ['/login', '/signup', '/favicon.ico']

# connect MongoDB
mongoose.connect MONGO_URL

# controllers
boardController = require './server/controllers/board_controller'
publicController = require './server/controllers/public_controller'

  
app = express()
app.configure ->
  # jade templates from templates dir
  app.use express.compress()
  app.set 'views', "#{__dirname}/server/templates"
  app.set 'view engine', 'jade'
  
  # serve static assets
  app.use('/assets', express.static("#{__dirname}/#{ASSET_BUILD_PATH}"))
  app.use('/images', express.static("#{__dirname}/images"))
   
  # logging
  app.use express.logger()
  
  app.use bodyParser.json()
  app.use bodyParser.urlencoded
    extended: true
    
  app.use multer(
    dest: './images/'
  )
  
  app.use session(
    secret: SESSION_SECRET
    resave: false
    saveUninitialized: false
  )
  
  app.use flash()
  
# public routes
app.get '/', publicController.index
app.get '/about', publicController.about

app.get '/board', boardController.index
app.post '/board/new', boardController.new

app.get '/board/:boardName', boardController.view
app.post '/board/:boardName/newThread', boardController.newThread
app.get '/board/:boardName/thread/:id', boardController.viewThread
app.post '/board/:boardName/thread/:id/post', boardController.postInThread

app.use (req, res) ->
  res.status 400
  res.render 'public/404'

module.exports = app
