# Post markup parser
_s = require 'underscore.string'

module.exports.parseMarkup = (boardName, threadID, text) ->
  words = _s.words text
  for word, index in words
    if _s.startsWith word, '&gt;&gt;'
      id = _s.ltrim word, '&gt;&gt;'
      words[index] = "<a href=\"/board/#{boardName}/thread/#{threadID}/#p#{id}\">"
      words[index] += "&gt;&gt;"
      words[index] += id
      words[index] += "</a>"
  return words.join ' '