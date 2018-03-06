#! /bin/bash

RAW_SPEECH=$1
RAW_MUSIC=$2
MIX_PATH=$3
RAW_MIX_PATH=tmp/raw_mix.mp3
SPEECH_PATH=tmp/resampled_speech.mp3

# Get sample rate from the music
SAMPLE_RATE=`soxi -r $RAW_MUSIC`

# Resample the voice so rate matches music
sox -M $RAW_SPEECH $RAW_SPEECH -r $SAMPLE_RATE $SPEECH_PATH

# Mix the voice and music together, boosting speech audio
sox -m -v 1.3 $SPEECH_PATH -v 0.7 $RAW_MUSIC $RAW_MIX_PATH norm

# Get duration of the voice track in seconds
SPEECH_LENGTH=`soxi -D $SPEECH_PATH`

# Add 15s to pad the fade.
STOP_POSITION=`echo "$SPEECH_LENGTH + 15" | bc -l`

# Fade out the mix 15s after the voice stops.
sox $RAW_MIX_PATH $MIX_PATH fade t 0 $STOP_POSITION 10

# Clean up temporary files.
rm $RAW_MIX_PATH $RAW_SPEECH $SPEECH_PATH $RAW_MUSIC