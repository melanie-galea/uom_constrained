#!/bin/bash
cd DeepSpeech
#rm -rf /root/.local/share/deepspeech/*
rm -rf ./checkpoints2/*
./bin/run-ldc93s1.sh
