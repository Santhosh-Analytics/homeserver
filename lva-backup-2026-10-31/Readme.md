
Cause: ALC257 mic gain too high (Capture 100% +30 dB, Internal Mic Boost +20 dB) → hiss saturated signal (silence RMS ~13k–22k, 100% clipping) → wake word never detected. Fix (card 1, not 0): amixer -c 1 sset 'Internal Mic Boost' 0 amixer -c 1 sset 'Capture' 50% sudo alsactl store 1 Result: silence RMS 96, peak 14%, okay_nabu detected. Note: don't run wpctl set-volume on the mic; PipeWire may reset hardware gain. Test: ~/lva-test/check.sh



## Home Assistant Local Voice Setup

The Home Assistant voice stack runs locally on the Debian laptop.

### Architecture

```text
Laptop microphone
      ↓
Linux Voice Assistant (LVA)
      ↓
Home Assistant
      ↓
Whisper
      ↓
Home Assistant Assist
      ↓
Piper
      ↓
Linux Voice Assistant
      ↓
Laptop speakers
```

### Containers

The voice setup uses three long-running containers:

1. **Home Assistant**
   - Main Home Assistant server
   - Port `8123`
   - Accessible from the home LAN

2. **Whisper**
   - Local speech-to-text
   - Model: `faster-whisper-tiny-int8`
   - Port `127.0.0.1:10300`
   - Localhost only

3. **Piper**
   - Local text-to-speech
   - Port `127.0.0.1:10200`
   - Localhost only

4. **Linux Voice Assistant**
   - Uses the laptop microphone and speakers as the Home Assistant voice satellite
   - Connected to Home Assistant through the ESPHome API
   - Port `192.168.29.239:6053`
   - LAN access allowed through UFW

### Linux audio

The laptop uses PipeWire with PulseAudio compatibility.

Input:

```text
alsa_input.pci-0000_04_00.6.analog-stereo
```

Output:

```text
alsa_output.pci-0000_04_00.6.analog-stereo
```

These exact devices are configured in the LVA `.env` file.

Using `default` for the LVA audio devices caused LVA to restart with:

```text
IndexError: no soundcard with id default
```

Changing the configuration to the actual PulseAudio source and sink fixed LVA startup.

### LVA TTS playback issue

Home Assistant successfully generated speech with Piper and sent the MP3 URL to Linux Voice Assistant, but no sound came from the Debian laptop speakers.

The LVA log showed:

```text
MpvMediaPlayer:Playing 1 URL(s)
```

but there was no corresponding audio playback stream.

The laptop speakers themselves worked correctly with `speaker-test`, and LVA could see the correct PulseAudio/PipeWire sink.

The problem was isolated to LVA's `libmpv` audio output.

### Workaround

LVA `1.1.15` was pinned and a small custom Docker image was created.

Original MPV configuration:

```python
self._mpv = mpv.MPV(
    audio_display=False,
    ...
)
```

Modified configuration:

```python
self._mpv = mpv.MPV(
    ao="pulse",
    audio_display=False,
    ...
)
```

This forces libmpv to use the PulseAudio backend instead of its default audio-output selection.

Custom files:

```text
lva/
├── docker-compose.yml
├── compose.override.yaml
├── Dockerfile
├── libmpv.py
├── .env
└── .env.example
```

The custom image is:

```text
local/linux-voice-assistant:pulse
```

Base image:

```text
ghcr.io/ohf-voice/linux-voice-assistant:1.1.15
```

After recreating LVA with this custom image, Home Assistant TTS successfully played through the Debian laptop speakers.

### Firewall

LAN-accessible services:

```text
8123/tcp  Home Assistant
6053/tcp  Linux Voice Assistant / ESPHome API
```

Both are restricted to:

```text
192.168.29.0/24
```

Internal voice services are bound only to localhost:

```text
127.0.0.1:10200  Piper
127.0.0.1:10300  Whisper English
```

Therefore no UFW LAN rules are needed for Piper or Whisper.

### Important

The LVA PulseAudio modification is a local workaround.

When upgrading Linux Voice Assistant, check whether the upstream audio-output problem has been fixed before rebuilding or removing the custom `ao="pulse"` modification.
