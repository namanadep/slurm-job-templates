#!/bin/bash
#SBATCH --job-name=openmp_demo
#SBATCH --output=openmp_demo_%j.out
#SBATCH --error=openmp_demo_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1G
#SBATCH --time=00:10:00
#SBATCH --partition=normal

# Export OMP_NUM_THREADS to match the allocated CPUs
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo "Job ID          : $SLURM_JOB_ID"
echo "Node            : $(hostname)"
echo "Allocated CPUs  : $SLURM_CPUS_PER_TASK"
echo "OMP_NUM_THREADS : $OMP_NUM_THREADS"
echo ""

# Compile and run a simple OpenMP C program
cat > /tmp/omp_demo_${SLURM_JOB_ID}.c << 'CSRC'
#include <stdio.h>
#include <omp.h>

int main() {
    printf("Running with %d OpenMP threads\n\n", omp_get_max_threads());

    #pragma omp parallel
    {
        int tid = omp_get_thread_num();
        int nthreads = omp_get_num_threads();
        printf("  Thread %d of %d: Hello from OpenMP!\n", tid, nthreads);
    }

    // Parallel pi approximation
    long N = 100000000L;
    double sum = 0.0;

    #pragma omp parallel for reduction(+:sum)
    for (long i = 0; i < N; i++) {
        double x = (i + 0.5) / N;
        sum += 4.0 / (1.0 + x * x);
    }

    printf("\nOpenMP Pi estimate (N=%ld): %.8f\n", N, sum / N);
    return 0;
}
CSRC

gcc -fopenmp -O2 -o /tmp/omp_demo_${SLURM_JOB_ID} /tmp/omp_demo_${SLURM_JOB_ID}.c
/tmp/omp_demo_${SLURM_JOB_ID}
rm -f /tmp/omp_demo_${SLURM_JOB_ID}{,.c}
