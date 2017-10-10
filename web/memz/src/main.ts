import './styles.scss';

const app = require('./app/Main.elm').Main.fullscreen();

// receive something from Elm
app.ports.getLocalStorageItem.subscribe(function (str) {
    console.log("got from Elm:", str);
});