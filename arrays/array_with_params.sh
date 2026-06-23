#!/bin/bash
#SBATCH --job-name=param_array
#SBATCH --output=param_array_%A_%a.out
#SBATCH --error=param_array_%A_%a.err
#SBATCH --array=0-4
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M
#SBATCH --time=00:10:00
#SBATCH --partition=normal

# Read parameters from file — one set per line
PARAM_FILE="$(dirname "$0")/params.txt"

# Extract the line corresponding to this task's index (0-based)
PARAMS=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$PARAM_FILE")
LEARNING_RATE=$(echo "$PARAMS" | awk '{print $1}')
BATCH_SIZE=$(echo "$PARAMS"    | awk '{print $2}')
EPOCHS=$(echo "$PARAMS"        | awk '{print $3}')

echo "=== Parameter Sweep Task $SLURM_ARRAY_TASK_ID ==="
echo "Learning rate : $LEARNING_RATE"
echo "Batch size    : $BATCH_SIZE"
echo "Epochs        : $EPOCHS"
echo ""

# Simulate training run
python3 - <<EOF
import math, random

lr     = float("$LEARNING_RATE")
batch  = int("$BATCH_SIZE")
epochs = int("$EPOCHS")

loss = 1.0
for epoch in range(1, epochs + 1):
    loss *= (1 - lr * (1 + 0.1 * random.gauss(0, 1)))
    loss = max(loss, 0.001)
    if epoch % max(1, epochs // 5) == 0:
        print(f"  Epoch {epoch:3d}/{epochs} | loss={loss:.4f}")

print(f"\nFinal loss for lr={lr}, batch={batch}, epochs={epochs}: {loss:.6f}")
EOF
