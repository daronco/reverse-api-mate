sendRequest = require("request")

Utils = require("../lib/utils")

# Application's default router, with the most generic routes.
module.exports = class Router

  constructor: (app) ->
    @app = app
    @registerRoutes()

  # Register all routes for the associated application.
  registerRoutes: ->

    # Simple request logger
    @app.all "*", (req, res, next) ->
      console.log "***", req.method, "request to", req.url, "from:", clientDataSimple(req)
      # console.log "*** headers", req.headers
      next()

    # @app.all "*", (req, res, next) ->
    #   start = Date.now()
    #   res.on 'finish', ->
    #     duration = Date.now() - start
    #     console.log "*** response:", req.method, "request to", req.url, "request responded [#{(duration / 1000.0)} secs]"
    #   next()

    @app.get "/", (req, res) ->
      res.render "index"

    @app.post "/", (req, res) ->
      sendTo = req.body["sendTo"]
      data = req.body["eventData"]
      console.log "*** posting event to'", sendTo, "' with the data:", data

      opt =
        url: sendTo
        timeout: 2000
        method: "POST"
        body: data
        headers:
          'Content-Type': 'application/x-www-form-urlencoded'
          'Content-Length': Buffer.byteLength(data)
      console.log "-- sending the request", opt
      sendRequest opt, (error, receivedRes, body) =>
        if error?
          console.log "-- sending received the error", error
          res.send(error)
        else
          console.log "-- sending received the response", body
          res.setHeader("Content-Type", "text/xml")
          res.send(body)

# Returns a simple string with a description of the client that made
# the request. It includes the IP address and the user agent.
clientDataSimple = (req) ->
  "ip " + Utils.ipFromRequest(req) + ", using " + req.headers["user-agent"]
