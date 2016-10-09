require('./main.css');

// Elm Setup
const Elm = require('./AudioPlayer.elm');

const root = document.getElementById('elm-audioplayer');
const app = Elm.AudioPlayer.embed(root);

// Subscribe to change in playhead messages
app.ports.setCurrentTime.subscribe((time) => {
  const audio = document.getElementById('elm-audio-file');
  audio.currentTime = time;
});

// Subscribe to change in playback speed messages
app.ports.setPlaybackRate.subscribe((rate) => {
  const audio = document.getElementById('elm-audio-file');
  audio.playbackRate = rate;
});

// Subscribe to play messages
app.ports.play.subscribe(() => {
  const audio = document.getElementById('elm-audio-file');
  audio.play();
});

// Subscribe to pause messages
app.ports.pause.subscribe(() => {
  const audio = document.getElementById('elm-audio-file');
  audio.pause();
});

