#!/bin/sh

killall conky
conky -d -c "$HOME/.conky/conky_dodo/conky_dodoCPU" &
conky -d -c "$HOME/.conky/conky_dodo/conky_dodoDATA" &

# WIP
conky -d -c "$HOME/.conky/conky_dodo/conky_dodoNET" &
