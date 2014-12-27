mongoose = require 'mongoose'
boardSchema = require './schemas/boardSchema'

module.exports = mongoose.model 'Board', boardSchema