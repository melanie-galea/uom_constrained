import optuna
import subprocess
import os
import sys
import shutil

from evaluate import calculate_score_report  # Assuming calculate_bleu_score is the function to compute BLEU score in evaluate.py


def objective(trial):
    # Define hyperparameters to tune
    lr = trial.suggest_loguniform('lr', 1e-5, 1e-2)
    dropout = trial.suggest_uniform('dropout', 0.0, 0.5)
    warmup_updates = trial.suggest_int('warmup_updates', 1000, 20000)
    weight_decay = trial.suggest_loguniform('weight_decay', 1e-5, 1e-3)

    # Fetch hyperparameters from command-line arguments
    fairseq_train = sys.argv[1]
    data_out = sys.argv[2]
    src_file = sys.argv[3]
    tgt_file = sys.argv[4]
    checkpoints = sys.argv[5]

    # Create directory for current trial
    trial_checkpoint_dir = os.path.join(checkpoints, f"trial_{trial.number}")
    os.makedirs(trial_checkpoint_dir, exist_ok=True)


    # Define command for training
    command = f"""{fairseq_train} {data_out} --source-lang {src_file} --target-lang {tgt_file} --arch lstm  --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
        --reset-dataloader --criterion label_smoothed_cross_entropy --label-smoothing 0.2 --lr-scheduler inverse_sqrt --warmup-updates {warmup_updates} --warmup-init-lr 1e-7 --lr {lr} --max-tokens-valid 2048   --weight-decay {weight_decay} --dropout {dropout} --max-update 1000000 --validate-interval-updates 1000 --save-interval 1 --save-dir {trial_checkpoint_dir} --max-tokens 8192 --max-source-positions 1024 --max-target-positions 1024 --validate-interval 1 --eval-bleu --eval-bleu-detok "space" --eval-bleu-args '{{"beam": 5}}' --eval-bleu-print-samples --patience 10 --best-checkpoint-metric "bleu" --maximize-best-checkpoint-metric --encoder-bidirectional"""

    # Execute command and get BLEU score
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        raise RuntimeError(f"Training failed with return code {result.returncode}.\n{result.stderr.decode()}")

    # Extract BLEU score from output
    bleu_score = extract_bleu_score(trial_checkpoint_dir)
    
    # Return the objective value (in this case, BLEU score)
    return bleu_score

def extract_bleu_score(checkpoint):
    
    # Get the current directory
    current_directory = os.getcwd()
    
    # List all files in the current directory
    files = os.listdir(current_directory)
    

    # Call eval.sh
    eval_command = "./eval.sh en mt data/ results_lstm/ " + checkpoint
    eval_result = subprocess.run(eval_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if eval_result.returncode != 0:
        raise RuntimeError(f"Error while executing eval.sh: {eval_result.stderr.decode()}")


    # Call calculate_bleu_score function from evaluate.py
    bleu_score = calculate_score_report("results_lstm/translations/mt_en/mt_en.bpe.hyp.detokenized", "original/mt_en/test.en", False)  # You may need to pass any necessary arguments
    return bleu_score
    

if __name__ == "__main__":
    # Check if the correct number of command-line arguments is provided
    if len(sys.argv) != 6:
        print("Usage: python hyperparam_tuning.py FAIRSEQ_TRAIN DATA_OUT SRC_FILE TGT_FILE CHECKPOINTS")
        sys.exit(1)

    # Create a study object and optimize hyperparameters
    study = optuna.create_study(direction='maximize')
    study.optimize(objective, n_trials=100)

    # Print best hyperparameters and objective value
    print("Best hyperparameters:", study.best_params)
    print("Best BLEU score:", study.best_value)
