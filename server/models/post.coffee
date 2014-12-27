mongoose = require 'mongoose'
postSchema = require './schemas/postSchema'

module.exports = mongoose.model 'Post', postSchema