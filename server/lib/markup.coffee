# Post markup parser
_s = require 'underscore.string'

module.exports.parseNewlineToBreakTag = (text) ->
  return String(text).replace(/\n/g, '<br>')

module.exports.parseCites = (boardName, threadID, text) ->
  words = _s.words text
  for word, index in words
    if _s.startsWith word, '&gt;&gt;'
      id = _s.ltrim word, '&gt;&gt;'
      words[index] = "<a href=\"/board/#{boardName}/thread/#{threadID}/#p#{id}\">"
      words[index] += "&gt;&gt;"
      words[index] += id
      words[index] += "</a>"
  return words.join ' '

module.exports.parseGreentext = (text) ->
  lines = text.split('<br>')
  for line, index in lines
    b1 = _s.startsWith line, '&gt;'
    b2 = not _s.startsWith line, '&gt;&gt;'
    if (_s.startsWith line, '&gt;') and not (_s.startsWith line, '&gt;&gt;')
      lines[index] = "<p class='greentext'>#{line}</p>"
  return lines.join '<br>'

module.exports.parseMarkup = (boardName, threadID, text) ->
  text = module.exports.parseNewlineToBreakTag text
  text = module.exports.parseCites boardName, threadID, text
  text = module.exports.parseGreentext text
  text = _s.rtrim text, '<br>' if _s.endsWith text, '<br>'
  return text