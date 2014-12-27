Board = require '../models/board'

publicController = {}

publicController.index = (req, res) ->
  res.render 'public/index'
    
publicController.about = (req, res) ->    
  res.render 'public/about'    

module.exports = publicController
