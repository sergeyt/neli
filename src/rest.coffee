# rest api
path = require 'path'
Nedb = require 'nedb'

# export express app plugin
module.exports = (app) ->
	# collections api
	app.get ':db', ls
	app.route(':db/:collection')
		.get(get_collection)
		.post(add_doc)

	# docs api
	app.route(':db/:collection/:id')
		.get(get_doc)
		.delete(del_doc)
		# TODO fix
		#.update(update_doc)

	# metadata
	app.route(':db/:collection/:id/metadata')
		.get(get_meta)
		# TODO fix
		#.update(update_meta)
	
	# permissions
	app.route(':db/:collection/:id/permissions')
		.get(get_permissions)
		# TODO fix
		#.update(set_permissions)

# dirs
root = path.dirname __dirname
datadir = path.join root, 'data'

# rest handlers

# loads collection
load_db = (req) ->
	dbname = req.params.db
	colname = req.params.collection
	dir = path.join datadir, dbname
	db = new Nedb path.join(dir, colname)
	db

serialize_doc = (doc) ->
	# todo add metadata
	doc

send_docs = (res, err, docs) ->
	return res.send {error: err} if err
	res.send(docs.map serialize_doc)

# lists databases
ls = (req, res) ->
	# todo get list of databases from data dir
	res.send(["docs"])

# GET db/collection handler
# TODO support ?selector={}
get_collection = (req, res) ->
	db = load_db req
	db.find {}, (err, docs) ->
		send_docs(res, err, docs)

# GET db/collection/id handler
get_doc = (req, res, doc_handler) ->
	db = load_db req
	id = req.params.id
	db.findOne {_id: id}, (err, doc) ->
		return res.send {error: err} if err
		json = if doc_handler then doc_handler(doc) else serialize_doc(doc)
		res.send json

# DELETE db/collection/id handler
del_doc = (req, res) ->
	db = load_db req
	id = req.params.id
	db.remove {_id: id}, (err, numRemoved) ->
		return res.send {error: err} if err
		res.send {ok: numRemoved}

# POST db/collection handler
add_doc = (req, res) ->
	db = load_db req
	doc = req.body
	now = new Date()
	# todo get user from request
	user = 'admin'
	doc.$metadata =
		version: 1
		CreatedBy: user
		Created: now
		ModifiedBy: user
		Modified: now
	db.insert doc, (err, newDoc) ->
		newDoc.$metadata.id = newDoc._id
		res.send serialize_doc(newDoc)

# UPDATE db/collection/id
update_doc = (req, res, update_handler) ->
	db = load_db req
	id = req.params.id
	# todo update last version
	db.findOne {_id: id}, (err, doc) ->
		return res.send {error: err} if err

		if update_handler
			update_handler doc, req.body
		else
			doc = _.extend {}, doc, req.body

		db.update {_id: id}, doc, (err) ->
			return res.send {error: err} if err
			res.send serialize_doc(doc)

# GET db/collection/id/metadata
get_meta = (req, res) ->
	get_doc req, res, (doc) -> doc.$metadata

# TODO update metadata
update_meta = (req, res) ->
	update_doc req, res, (doc) -> doc.$metadata

# TODO permissions
get_permissions = (req, res) ->

set_permissions = (req, res) ->

