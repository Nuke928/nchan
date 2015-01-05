mongoose = require 'mongoose'

module.exports = mongoose.Schema(
  name:
    type: String
    default: 'Anonymous'
  
  date:
    type: Date
    default: Date.now
  
  image: String
  
  id:
    type: Number
  
  isOp:
    type: Boolean
    default: false
  
  text:
    type: String
    maxLength: 500

  file: String
)