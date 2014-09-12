// This is a simple wrapper to run the app with 'node app.js'

require("coffee-script");

// Start the server
app = require('./app.coffee');
port = 3001
app.listen(port);
if (app.address() === null) {
  console.log('Could not bind to port', port);
  console.log('Aborting.');
  process.exit(1);
}

console.log("*** Server listening on port", app.address().port, "in", app.settings.env.toUpperCase(), "mode");
