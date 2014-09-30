_ = require("lodash")
sendRequest = require("request")
sha1 = require("sha1")
url = require("url")

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
      ip = req.body["senderIP"]
      salt = req.body["senderSalt"]
      timestamp = req.body["timestamp"]

      headers =
        'Content-Type': 'application/x-www-form-urlencoded'
        'Content-Length': Buffer.byteLength(data)
      if ip? and not _.isEmpty(ip)
        console.log "-- setting the IP to", ip
        # the LB tries this header before getting the IP from request.connection.remoteAddress
        headers['x-real-ip'] = ip

      data += "&ts=#{timestamp}"

      csUrl = sendTo + "?" + data
      console.log "-- calculating checksum for", csUrl
      data = "#{data}&checksum=#{checksum(csUrl, salt)}"

      opt =
        url: sendTo
        timeout: 2000
        method: "POST"
        body: data
        headers: headers
      console.log "-- sending the request", opt
      sendRequest opt, (error, receivedRes, body) =>
        if error?
          console.log "-- sending received the error", error
          res.send(error)
        else
          console.log "-- sending received the response", body
          res.setHeader("Content-Type", "text/xml")
          res.send(body)

# Calculates the checksum given a url `fullUrl` and a `salt`.
checksum = (fullUrl, salt) ->
  query = queryFromUrl(fullUrl)
  method = methodFromUrl(fullUrl)
  sha1(method + query + salt)

queryFromUrl = (fullUrl) ->
  # Returns the query without the checksum.
  # We can't use url.parse() because it would change the encoding
  # and the checksum wouldn't match. We need the url exactly as
  # the client sent us.
  query = fullUrl.replace(/&checksum=[^&]*/, '')
  query = query.replace(/checksum=[^&]*&/, '')
  query = query.replace(/checksum=[^&]*$/, '')
  matched = query.match(/\?(.*)/)
  if matched?
    matched[1]
  else
    ''

methodFromUrl = (fullUrl) ->
  urlObj = url.parse(fullUrl, true)
  urlObj.pathname.substr "/bigbluebutton/api/".length

# Returns a simple string with a description of the client that made
# the request. It includes the IP address and the user agent.
clientDataSimple = (req) ->
  "ip " + Utils.ipFromRequest(req) + ", using " + req.headers["user-agent"]
