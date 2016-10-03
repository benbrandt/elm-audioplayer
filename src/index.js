require('./main.css');

var Elm = require('./Main.elm');

var root  = document.getElementById('root');

var app = Elm.Main.embed(root);

app.ports.setCurrentTime.subscribe(function (time) {
  var audio = document.getElementById('audio-player');
  audio.currentTime = time;
});

