_ = require './utils'
agentReq = require './agent_requests'

series = {}
edits = []

module.exports = (seriesData)->
  for k, qid of seriesData
    [letter, rank] = k
    series[letter] or= []
    series[letter].push {rank: Number(rank), qid: qid}

  _.log series, 'series before ranking'

  for serie, list of series
    serie = _.sortBy list, 'rank'
    for el, i in serie
      { qid } = el
      previous = previousEl i, serie
      next = nextEl i, serie
      if previous? then edits.push follows(qid, previous)
      if next? then edits.push followedBy(qid, next)

  _.log edits, 'edits'

  editOne()

editOne = ->
  if edits.length > 0
    nextEdit = edits.shift()
    agentReq.edit nextEdit
    .then -> setTimeout editOne, 1000
    .catch _.Error('editOne')

  else
    console.log 'done!'.green

previousEl = (i, serie)-> serie[i-1]?.qid
nextEl = (i, serie)-> serie[i+1]?.qid

follows = (subject, object)-> editData subject, 'P155', object
followedBy = (subject, object)-> editData subject, 'P156', object

editData = (subject, predicate, object)->
  entity: subject
  property: predicate
  value: object
