#!/bin/bash -x

set -o verbose
find ./data/childes/es/chat/ -name *.cha |/opt/local/bin/parallel -j+0 --eta "./scripts/extract-speech.awk {}"  > experiments/all_es.tab	

