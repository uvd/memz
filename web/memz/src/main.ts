import './styles.scss';

const app = require('./app/Main.elm').Main.fullscreen();

// receive something from Elm
app.ports.getLocalStorageItem.subscribe(function (key) {
    localStorage.getItem(key);
});

app.ports.setLocalStorageItem.subscribe(function ([key, value]) {
    localStorage.setItem(key, value);
});