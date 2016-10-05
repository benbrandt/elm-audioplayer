require('./main.css');

const Elm = require('./Main.elm');

const root = document.getElementById('elm-audioplayer');

const app = Elm.Main.embed(root);

app.ports.setCurrentTime.subscribe((time) => {
  const audio = document.getElementById('elm-audio-file');
  audio.currentTime = time;
});

app.ports.setPlaybackRate.subscribe((rate) => {
  const audio = document.getElementById('elm-audio-file');
  audio.playbackRate = rate;
});

app.ports.play.subscribe(() => {
  const audio = document.getElementById('elm-audio-file');
  audio.play();
});

app.ports.pause.subscribe(() => {
  const audio = document.getElementById('elm-audio-file');
  audio.pause();
});

