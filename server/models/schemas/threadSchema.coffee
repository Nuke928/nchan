mongoose = require 'mongoose'
postSchema = require './postSchema'

module.exports = mongoose.Schema(
  id: Number
  posts: [postSchema]
)