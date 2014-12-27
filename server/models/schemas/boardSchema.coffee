mongoose = require 'mongoose'
threadSchema = require './threadSchema'

boardSchema = mongoose.Schema(
  name:
    type: String
    unique: true
  threads: [threadSchema]
  postCount:
    type: Number
    default: 0
)

boardSchema.statics.increasePostCount = (id, cb) ->
  @findByIdAndUpdate(id,
    $inc:
      postCount: 1
  , cb
  )

module.exports = boardSchema