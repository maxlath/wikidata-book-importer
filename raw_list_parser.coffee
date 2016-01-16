fs = require 'fs'
filePathBase = __dirname + '/source/foucault'
_ = require './lib/utils'

parseDoc = ->
  list = fs.readFileSync "#{filePathBase}_raw", 'utf-8'
    .split '\n'
    .map parseLine

  json = JSON.stringify list, null, 2
  fs.writeFileSync "#{filePathBase}.json", json
  console.log 'done!'.green

isbn10Re = /\(?ISBN\s([\dX-]{10,12})\)?/
isbn10ReExclude = /\(?ISBN\s[\dX-]{10,12}\)?/
isbn13Re = /\(?ISBN\s([\dX-]{13,17})\)?/
isbn13ReExclude = /\(?ISBN\s[\dX-]{13,17}\)?/
pagesRe = /,?\s(\d{1,5})\sp\.\s?/
pagesReExclude = /,?\s\d{1,5}\sp\. ?/
yearRe = /,?\s(\d{4}),?/
# yearReExclude = /,?\s\d{4},?/

collectionRe = /, coll.[^,]+,/

city =
  Paris: 'Q90'
  Louvain: 'Q118958'
  'Fontfroide-le-Haut': 'Q746415'

publishers =
  Gallimard: 'Q273819'
  Vrin: 'Q3237914'
  'Presses universitaires de Louvain': 'Q3402585'
  'Fata Morgana': 'Q3579326'
  Plon: 'Q3392522'

# aliasing
aliases = {}
for k, v of publishers
  aliases["Éditions #{k}"] = v
  aliases["ed. #{k}"] = v
  aliases["Librairie #{k}"] = v

_.extend publishers, aliases

parseLine = (line)->
  data = {}
  line = line.replace collectionRe, ','
  line = getValueRe 'P957', isbn10Re, isbn10ReExclude, line, data
  line = getValueRe 'P212', isbn13Re, isbn13ReExclude, line, data
  line = getValueRe 'P1104', pagesRe, pagesReExclude, line, data, Number
  # do not replace years, just pick the last one
  line = getValueRe 'P577', yearRe, null, line, data

  line = getValueMatch 'P123', publishers, line, data
  line = getValueMatch 'P291', city, line, data, false

  data.label = line
    .replace /[\W\s]+‎$/, ''
    .replace /, $/, ''

  return data

getValueMatch = (pid, dict, line, data, keepRight=true)->
  list = Object.keys dict
  for el in list
    parts = line.split el
    if parts.length is 2
      data[pid] = dict[el]
      if keepRight then return parts.join(' ').replace(',,', ',').trim()
      else return parts[0]
  return line

getValueRe = (pid, reMatch, reExclude, line, data, convert)->
  val = line.match(reMatch)?[0].replace reMatch, '$1'
  convert or= _.identity
  if val? then data[pid] = convert val
  if reExclude? then return line.split(reExclude).join(' ').trim()
  else return line

parseDoc()
