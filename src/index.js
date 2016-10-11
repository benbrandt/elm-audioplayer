require('./main.css');

// Elm Setup
const Elm = require('./AudioPlayer.elm');

const root = document.getElementById('elm-audioplayer');

// Get user config values
const logo = root.getAttribute('data-logo');
const speedControl = root.getAttribute('data-speedcontrol') === 'true';
const volumeControl = root.getAttribute('data-volumeControl') === 'true';

const app = Elm.AudioPlayer.embed(root, {
  logo,
  speedControl,
  volumeControl,
});

// Send audio files to elm audio player
const audioFiles = document.getElementsByClassName('elm-audioplayer-media');

// Update audio file in audioplayer
function sendAudioData(event) {
  event.preventDefault();

  // Get File Attributes
  const mediaUrl = this.getAttribute('href');
  const thumbnail = this.getAttribute('data-thumbnail');
  const title = this.getAttribute('data-title');
  const artist = this.getAttribute('data-artist');

  // Send to Elm
  app.ports.updateAudioFile.send({
    mediaUrl,
    thumbnail,
    title,
    artist,
  });
}

for (let i = 0; i < audioFiles.length; i += 1) {
  audioFiles[i].addEventListener('click', sendAudioData);
}

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

