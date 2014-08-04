path = require 'path'
express = require 'express'

# express modules
cors = require 'cors'
morgan = require 'morgan'
compression = require 'compression'
cookieParser = require 'cookie-parser'
methodOverride = require 'method-override'
bodyParser = require 'body-parser'

# app modules
rest = require './rest'

root = path.dirname __dirname

app = express()

# configure express app
app.set 'port', process.env.PORT || 1111
app.set 'host', 'http://localhost:' + app.get('port')
app.set 'view engine', 'jade'
app.set 'views', root + '/views'

# express middlewares
app.use cors() # prevent any problem with CORS
app.use morgan("dev", {})
app.use compression()
app.use cookieParser()
app.use bodyParser.json()
app.use methodOverride()

# static content
app.use '/public', express.static root + '/public'

# send any error as json
app.use (req, res, next) ->
	try
		next()
	catch error
		res.send {error: error}

# injecting app modules
rest(app);

# error handler
app.use (req, res) ->
	res.status(404).send 'Sorry, cant find that!'

# db init
require('./dbinit')()

# now run server
port = app.get 'port'
app.listen port
console.log "Listening on port #{port}"
