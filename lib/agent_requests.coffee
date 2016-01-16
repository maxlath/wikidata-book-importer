breq = require 'bluereq'
agent = 'http://localhost:4115'
_ = require './utils'
wdk = require 'wikidata-sdk'

module.exports =
  create: (data)-> breq.post "#{agent}/create", data
  edit: (data)-> breq.post "#{agent}/edit", data
  get: (qid)->
    breq.get wdk.getEntities(qid)
    .then _.property('body')
    .then (body)->
      entity = body.entities[qid]
      _.log entity, 'entity'
      entity.claims = wdk.simplifyClaims entity.claims
      return entity
