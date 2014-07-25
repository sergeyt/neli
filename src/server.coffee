path = require 'path'
express = require 'express'

root = path.dirname __dirname

app = express()

# configure express app
app.set 'port', process.env.PORT || 1111
app.set 'host', 'http://localhost:' + app.get('port')
app.set 'view engine', 'jade'
app.set 'views', root + '/views'

# config middlewares
# Prevent any problem with CORS
app.use (req, res, next) ->
	res.header 'Access-Control-Allow-Origin', '*'
	next()

app.use(require('morgan')("dev", {}))
app.use(require('compression')())
app.use(require('cookie-parser')())
app.use(require('body-parser')())
app.use(require('method-override')())

# static content
app.use '/public', express.static root + '/public'

# http handlers
app.get '/', (req, res) ->
	res.render 'index', {wikis: populateWikis()}

# inject docs rest interface
require('./rest')(app);

# error handler
app.use (req, res) ->
	res.send 404, 'Sorry, cant find that!'

# now run server
port = app.get 'port'
app.listen port
console.log "Listening on port #{port}"
