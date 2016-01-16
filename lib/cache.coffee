bluebird = require 'bluebird'
dataPath = './data'
_ = require './utils'
level = require 'level-party'
db = level dataPath, { encoding: 'json' }

dbGet = bluebird.promisify db.get.bind(db)
dbSet = bluebird.promisify db.put.bind(db)

cache = {}

module.exports =
  get: (key, request)->
    console.log 'GET'
    dbGet key
    .catch (err)->
      if err.notFound
        request()
        .then (res)-> set key, res
      else throw err

set = (key, value)->
  console.log 'SET'
  dbSet key, value
  .then -> return value
