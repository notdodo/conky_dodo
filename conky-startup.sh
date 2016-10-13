#!/bin/sh

killall conky
conky -d -c "/home/dodo/.conky/Dodo/conky_dodoCPU" &
conky -d -c "/home/dodo/.conky/Dodo/conky_dodoDATA" &
