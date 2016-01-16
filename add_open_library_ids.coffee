# TO EDIT
olId = 'OL4346031A'
name = 'foucault'


addOpenLibraryIds = require './lib/add_open_library_ids'
addOpenLibraryIds
  olId: olId
  dataPathBase: "#{__dirname}/source/#{name}"
