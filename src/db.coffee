fs = require 'fs'
path = require 'path'
Nedb = require 'nedb'

root = path.dirname __dirname
dataDir = path.join root, 'data'

# todo support list of collections
module.exports = (name) ->
	# ensure data and db dirs
	fs.mkdirSync dataDir unless fs.existsSync dataDir

	dir = path.join dataDir, name
	fs.mkdirSync dir unless fs.existsSync dir

	db =
		name: name
		collection: (collectionName) ->
			# load db
			dbfile = path.join dir, collectionName + ".nedb"
			new Nedb {filename: dbfile, autoload: true}
	db
