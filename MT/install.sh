#!/bin/bash
pip install omegaconf
pip install sentencepiece
pip install fairseq
pip install pyonmttok
pip install optuna
pip uninstall -y sacrebleu; pip install sacrebleu==1.5.1

