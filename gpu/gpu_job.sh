#!/bin/bash
#SBATCH --job-name=gpu_demo
#SBATCH --output=gpu_demo_%j.out
#SBATCH --error=gpu_demo_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00
#SBATCH --partition=debug

echo "Job ID         : $SLURM_JOB_ID"
echo "Node           : $(hostname)"
echo "GPU allocated  : $SLURM_JOB_GPUS"
echo ""

# Show GPU info
nvidia-smi --query-gpu=name,memory.total,driver_version \
           --format=csv,noheader

echo ""
echo "Running CUDA matrix multiply benchmark..."

python3 - <<'EOF'
import subprocess, sys

try:
    import torch
    device = torch.device("cuda")
    print(f"PyTorch CUDA device : {torch.cuda.get_device_name(0)}")
    print(f"CUDA memory total   : {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")

    import time
    N = 4096
    A = torch.randn(N, N, device=device)
    B = torch.randn(N, N, device=device)

    torch.cuda.synchronize()
    t0 = time.perf_counter()
    C = A @ B
    torch.cuda.synchronize()
    elapsed = time.perf_counter() - t0

    flops = 2 * N**3
    print(f"\nMatrix multiply {N}x{N}: {elapsed*1000:.1f} ms")
    print(f"Throughput: {flops / elapsed / 1e12:.2f} TFLOPS")

except ImportError:
    print("PyTorch not found - install with: pip install torch --index-url https://download.pytorch.org/whl/cu121")
    sys.exit(1)
EOF
