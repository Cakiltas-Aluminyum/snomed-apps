express =        require 'express'
engines =        require 'consolidate'

routes  =        require './routes'

exports.startServer = (config, callback) ->
  port = process.env.PORT or config.server.port
  app = express()
  server = app.listen port, ->
    console.log "Express server listening on port %d in %s mode", server.address().port, app.settings.env

  #CORS middleware
  allowCrossDomain = (req, res, next) ->
    res.header "Access-Control-Allow-Origin", config.allowedDomains
    res.header "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE"
    res.header "Access-Control-Allow-Headers", "Content-Type"
    next()


  app.configure ->
    app.set 'port', port
    app.set 'views', config.server.views.path
    app.engine config.server.views.extension, engines[config.server.views.compileWith]
    app.set 'view engine', config.server.views.extension
    app.use express.favicon()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.compress()
    app.use allowCrossDomain
    app.use config.server.base, app.router
    app.use express.static(config.watch.compiledDir)

  app.configure 'development', ->
    app.use express.errorHandler()

  app.post '/api/refsets', routes.refsetsPost()
  app.get '/api/refsets/:publicId', routes.refset()
  app.get '/api/refsets', routes.refsets()


  app.get '/', routes.index(config)
  app.get '/:publicId', routes.index(config)

  callback(server)



#http://stackoverflow.com/questions/17515981/reverse-proxy-to-couchdb-hangs-on-post-and-put-in-node-js