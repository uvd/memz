
require('./app/Stylesheets')

const config = require('config');

const app = require('./app/Main.elm').Main.fullscreen({
    baseUrl: config.BASE_URL
});

// receive something from Elm
app.ports.getLocalStorageItem.subscribe(function (key) {
    const storedItem = localStorage.getItem(key);
    app.ports.getLocalStorageItemResponse.send([key, storedItem]);
});

app.ports.setLocalStorageItem.subscribe(function ([key, value]) {
    localStorage.setItem(key, value);
});