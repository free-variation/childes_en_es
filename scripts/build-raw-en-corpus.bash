#!/bin/bash -x

set -o verbose
find ./data/childes/chat/ -name *.cha |/usr/bin/parallel -j+0 --eta "./scripts/extract-speech.awk {}"  > experiments/all_en.tab	

