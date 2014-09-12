express = require("express")
i18n = require("i18n")
RedisStore = require('connect-redis')(express)

Router = require("./routes/router")

# ## Command line parsing
# parser = require('commander');
# parser
#   .version(config.lb.version.full)
#   .option("-p, --port [value]", "Port to listen to [8080]", 3000)
#   .option("-l, --loglevel [2]", "Set the loglevel [0:error, 1:warning, 2:info, 3:debug, 9:off]", 2)
#   .option("-a, --algorithm [cpu]", "Load balancing algorithm from the folder ./lib/algorithms/", config.lb.algorithm)
#   .option("-c, --colors", "Colored output", false)
#   .parse(process.argv);
# config.lb.port = parser.port if (parser.port)
# config.lb.proxy = parseInt(parser.proxy) == 1 if (parser.proxy)
# config.lb.algorithm = parser.algorithm

app = module.exports = express.createServer()

app.configure ->
  app.use express.cookieParser()
  app.use express.static(__dirname + "/public")
  app.use require("connect-assets")()
  app.use express.session
    store: new RedisStore()
    secret: '01234567890123456789012345678901abcd'
  app.set "views", __dirname + "/views"
  app.set "view options", { layout: false }
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use i18n.init
  app.use app.router
  app.enable "jsonp callback"

app.configure "development", ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure "production", ->
  app.use express.errorHandler()
  app.use require("connect-assets")
    detectChanges: false

app.helpers
  __i: i18n.__,
  __n: i18n.__n
  h_locale: i18n.getLocale
  h_environment: app.settings.env

router = new Router(app)
