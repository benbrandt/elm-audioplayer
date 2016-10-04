require('./main.css');

var Elm = require('./Main.elm');

var root  = document.getElementById('elm-audioplayer');

var app = Elm.Main.embed(root);

app.ports.setCurrentTime.subscribe(function (time) {
  var audio = document.getElementById('elm-audio-file');
  audio.currentTime = time;
});

app.ports.setPlaybackRate.subscribe(function(rate) {
  var audio = document.getElementById('elm-audio-file');
  audio.playbackRate = rate;
});

app.ports.play.subscribe(function() {
  var audio = document.getElementById('elm-audio-file');
  audio.play();
});

app.ports.pause.subscribe(function() {
  var audio = document.getElementById('elm-audio-file');
  audio.pause();
});

