import './styles.scss';

const app = require('./app/Main.elm').Main.fullscreen();

// receive something from Elm
app.ports.getLocalStorageItem.subscribe(function (key) {
    const storedItem = localStorage.getItem(key);
    app.ports.getLocalStorageItemResponse.send([key, storedItem]);
});

app.ports.setLocalStorageItem.subscribe(function ([key, value]) {
    localStorage.setItem(key, value);
});