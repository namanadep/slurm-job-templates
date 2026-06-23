#!/bin/bash
#SBATCH --job-name=array_demo
#SBATCH --output=array_demo_%A_%a.out
#SBATCH --error=array_demo_%A_%a.err
#SBATCH --array=1-8
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M
#SBATCH --time=00:05:00
#SBATCH --partition=normal

# %A = master job ID, %a = array task index
echo "=== Array Job Task ==="
echo "Master Job ID : $SLURM_ARRAY_JOB_ID"
echo "Task Index    : $SLURM_ARRAY_TASK_ID"
echo "Node          : $(hostname)"
echo "Start time    : $(date)"
echo ""

# Each task processes a different input value
INPUT_VALUE=$((SLURM_ARRAY_TASK_ID * 10))
RESULT=$(python3 -c "
import math
x = $INPUT_VALUE
result = math.sqrt(x) * math.log(x + 1)
print(f'f({x}) = sqrt({x}) * ln({x}+1) = {result:.4f}')
")

echo "Task $SLURM_ARRAY_TASK_ID: $RESULT"
echo ""
echo "End time: $(date)"
