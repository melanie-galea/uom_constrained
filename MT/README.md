# Machine Translation
This folder contains the scripts used to preprocess, train and tune the machine translation model.

Scripts starting with "batch*" are used to start running the jobs in a SLURM cluster. The scripts are the following:
1. `preprocessing.sh` - Preprocesses the data and trains a sentencepiece model.
2. `run_baseline_system_lstm.sh`, `run_baseline_system_base.sh` and `run_baseline_system_large.sh` - Trains the LSTM, baseline transformer model and the large transformer model respectively
3. `hyperparam.sh` - Performs hyperparameter tuning for the best performing (LSTM) model