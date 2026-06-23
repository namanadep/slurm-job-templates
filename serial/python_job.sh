#!/bin/bash
#SBATCH --job-name=pi_estimate
#SBATCH --output=pi_estimate_%j.out
#SBATCH --error=pi_estimate_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=512M
#SBATCH --time=00:10:00
#SBATCH --partition=normal

echo "Job ID      : $SLURM_JOB_ID"
echo "Node        : $(hostname)"
echo "Start time  : $(date)"
echo ""

python3 - <<'EOF'
import random, math

N = 5_000_000
inside = sum(
    1 for _ in range(N)
    if math.sqrt(random.random()**2 + random.random()**2) < 1.0
)
pi = 4 * inside / N
print(f"Monte Carlo Pi estimate (N={N:,}): {pi:.6f}")
print(f"True Pi:                           {math.pi:.6f}")
print(f"Error:                             {abs(pi - math.pi):.6f}")
EOF

echo ""
echo "End time: $(date)"
