{ post, editSeries } = require './lib/post'

firstName = 'Michel'
lastName = 'Foucault'

commonData =
  author: 'Q44272'
  lang: 'fr'
  field: 'Q5891' #philo
  descriptionsBase: "#{firstName} #{lastName}"

  summary: 'import from French Wikipedia'

key = lastName.toLowerCase()
newEntities = require "./source/#{key}_enriched.json"

postOne = ->
  if newEntities.length > 0
    next = newEntities.shift()
    post commonData, next
    .then -> setTimeout postOne, 5000
    .catch (err)->
      if err.status_verbose is 'entity already added'
        console.log 'fast forwarding...'.grey
        setTimeout postOne, 100
      else throw err
  else
    console.log 'starting to edit series...'.grey
    editSeries()

postOne()
