breq = require 'bluereq'
fs = require 'fs'
agent = 'http://localhost:4115'
_ = require './utils'
_.extend _, require('inv-loggers')
fuzzy = require 'fuzzy.js'
toAscii = require('fold-to-ascii').fold
cache = require './cache'

module.exports = (data)->
  { olId, dataPathBase } = data

  entitiesData = require "#{dataPathBase}.json"

  url = "http://openlibrary.org/search.json?author=#{olId}"

  parseItem = (item)->
    { title, key } = item
    _.log title, 'title'
    for entity in entitiesData
      alignedLabel = toAscii entity.label.toLowerCase()
      alignedTitle = toAscii title.toLowerCase()
      { score } = fuzzy alignedTitle, alignedLabel
      closeLength = Math.abs(alignedLabel.length-title.length) < 5
      if score > 25 and closeLength
        _.log title, entity.label
        entity.score = score
        entity.OLtitle = title
        entity.P648 = key.replace '/works/', ''

  parseOpenLibraryResponse = (body)->
    for item in body.docs
      parseItem item

  cache.get url, request.bind(null, url)
  .then parseOpenLibraryResponse
  .then ->
    json = JSON.stringify entitiesData, null, 2
    fs.writeFileSync "#{dataPathBase}_enriched.json", json
  .catch _.Error('err')


request = (url)->
  breq.get url
  .then _.property('body')
