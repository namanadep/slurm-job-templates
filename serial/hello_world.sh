#!/bin/bash
#SBATCH --job-name=hello_world
#SBATCH --output=hello_world_%j.out
#SBATCH --error=hello_world_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M
#SBATCH --time=00:05:00
#SBATCH --partition=normal

echo "Job started at $(date)"
echo "Running on node: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Allocated CPUs: $SLURM_CPUS_PER_TASK"
echo ""
echo "Hello from Slurm!"

# Simulate some computation
for i in $(seq 1 5); do
    echo "Processing step $i / 5 ..."
    sleep 1
done

echo ""
echo "Job finished at $(date)"
