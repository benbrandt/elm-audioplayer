require('./main.css');

var Elm = require('./Main.elm');

var root  = document.getElementById('root');

var app = Elm.Main.embed(root);

app.ports.setCurrentTime.subscribe(function (time) {
  var audio = document.getElementById('elm-audio-file');
  audio.currentTime = time;
});

app.ports.toggleAudioState.subscribe(function (playing) {
  var audio = document.getElementById('elm-audio-file');
  playing ? audio.play() : audio.pause();
});

