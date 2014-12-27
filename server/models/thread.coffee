mongoose = require 'mongoose'
threadSchema = require './schemas/threadSchema'

module.exports = mongoose.model 'Thread', threadSchema