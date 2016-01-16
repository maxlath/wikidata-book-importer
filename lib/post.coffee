agentReq = require './agent_requests'
_ = require './utils'
silentKeys = ['id', 'score', 'OLtitle', 'serie', 'authorsTextList']
editSeries = require './edit_series'
fs = require 'fs'

langQids =
  fr: 'Q150'

seriesPath = __dirname + '/series_data.json'
series = require(seriesPath) or {}

module.exports =
  post: (commonData, entity)->
    data = buildData commonData, entity

    { id, serie } = entity

    if id
      _.log entity, 'entity already exist'
      edit data
      .then prepareSeries.bind(null, serie)

    else
      console.log 'CREATING'.green, data.labels.en
      createOrEdit data
      .then prepareSeries.bind(null, serie)

  editSeries: -> editSeries series

edit = (data)->
  agentReq.get data.id
  .then (entity)->
    for k, v of entity.claims
      # avoid to override data
      delete data.claims[k]

    for k, v of entity.labels
      console.log 'deleting'.grey, k, data.labels[k]
      delete data.labels[k]

    for k, v of entity.descriptions
      delete data.descriptions[k]

    # if Object.keys(data.labels) is 0
      # delete data.labels

    _.log data, 'DATA FOR EDIT'
    return createOrEdit data

createOrEdit = (data)->
  agentReq.create data
  .then (res)->
    { statusCode, statusMessage, body } = res
    _.log body, 'createOrEdit res'
    if statusCode >= 400
      err = new Error statusMessage
      if _.isObject body then _.extend err, body
      err.statusCode = statusCode
      throw err
    else
      return body

prepareSeries = (seriesId, body)->
  qid = body.entity.id
  _.log qid, 'new qid'
  if seriesId?
    series[seriesId] = qid

    json = JSON.stringify series, null, 2
    _.log json, 'series'
    fs.writeFileSync seriesPath, json

  return body

buildData = (commonData, entity)->
  { author, descriptionsBase, lang, summary, field } = commonData
  labels = {}
  claims = {}

  for k, v of entity
    if k is 'label' then labels[lang] = labels.en = v
    else if /P\d+/.test k then claims[k] = v
    else unless k in silentKeys
      throw new Error "unknown key: #{k}"

  # instance of
  claims.P31 or= 'Q571'
  # author
  claims.P50 or= []
  unless _.isArray claims.P50 then claims.P50 = [ claims.P50 ]
  claims.P50.push author
  # field of work
  claims.P101 = field
  # original language
  claims.P364 = langQids[lang]
  # title
  claims.P1476 = { text: labels[lang], language: lang }
  # subtitle
  if claims.P1680?
    claims.P1680 = { text: claims.P1680, language: lang }

  { id, authorsTextList } = entity

  data =
    # pass a key to make sure this entity isn't added twice
    key: labels[lang]
    labels: labels
    descriptions: buildDescriptions(descriptionsBase, authorsTextList)
    claims: claims
    summary: summary

  if id? then data.id = id

  return _.log data, 'data'

buildDescriptions = (base, custom)->
  text = custom or base
  return descriptions =
    fr: "livre de #{text}"
    en: "book by #{text}"
