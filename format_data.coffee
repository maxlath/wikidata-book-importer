require 'colors'
dataPath = './source/deleuze.json'
data = require dataPath
fs = require 'fs'
isbn = require('isbn2').ISBN

hyphenate = (text)-> isbn.hyphenate text.trim().replace(/\W/g, '')

data = data.map (entity)->
  { P212, P957 } = entity
  if P212? then entity.P212 = hyphenate P212
  if P957? then entity.P957 = hyphenate P957
  return entity

json = JSON.stringify data, null, 2
fs.writeFileSync dataPath, json

console.log 'done!'.green