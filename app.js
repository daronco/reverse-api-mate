// This is a simple wrapper to run the app with 'node app.js'

require("coffee-script");

// Start the server
app = require('./app.coffee');
app.listen(3000);
if (app.address() === null) {
  console.log('Could not bind to port', 3000);
  console.log('Aborting.');
  process.exit(1);
}

console.log("*** Server listening on port", app.address().port, "in", app.settings.env.toUpperCase(), "mode");
