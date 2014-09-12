Utils = exports

# Returns the IP address of the client that made a request `req`.
# If can not determine the IP, returns `127.0.0.1`.
Utils.ipFromRequest = (req) ->
  # the first ip in the list if the ip of the client
  # the others are proxys between him and us
  if req.headers?["x-forwarded-for"]?
    ips = req.headers["x-forwarded-for"].split(",")
    ipAddress = ips[0]?.trim()

  # fallbacks
  ipAddress ||= req.headers?["x-real-ip"] # when behind nginx
  ipAddress ||= req.connection?.remoteAddress # unless ipAddress?
  ipAddress ||= "127.0.0.1" # invalid
  ipAddress
