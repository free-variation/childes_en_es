#!/bin/bash

cat ./scripts/mlu_header.txt
find ./data/childes/chat -name "*.cha" -exec ./bin/mlu-$(uname) -d1 -f -t%mor 2> /dev/null {} \;
find ./data/childes/es/chat -name "*.cha" -exec ./bin/mlu-$(uname) -d1 -f -t%mor 2> /dev/null {} \;
