#!/bin/bash
#SBATCH --job-name=mpi_demo
#SBATCH --output=mpi_demo_%j.out
#SBATCH --error=mpi_demo_%j.err
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=512M
#SBATCH --time=00:15:00
#SBATCH --partition=normal

echo "Job ID              : $SLURM_JOB_ID"
echo "Nodes allocated     : $SLURM_JOB_NUM_NODES"
echo "Total MPI ranks     : $SLURM_NTASKS"
echo "Ranks per node      : $SLURM_NTASKS_PER_NODE"
echo "Node list           : $SLURM_JOB_NODELIST"
echo ""

# Compile a simple MPI scatter/reduce program
cat > /tmp/mpi_demo_${SLURM_JOB_ID}.c << 'CSRC'
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Each rank computes a partial sum of 1/i
    long N = 10000000L;
    long chunk = N / size;
    long start = rank * chunk + 1;
    long end   = (rank == size - 1) ? N : start + chunk - 1;

    double partial = 0.0;
    for (long i = start; i <= end; i++)
        partial += 1.0 / (double)i;

    double total = 0.0;
    MPI_Reduce(&partial, &total, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Harmonic sum H(%ld) across %d MPI ranks = %.8f\n", N, size, total);
    }

    printf("Rank %d/%d on %s: partial sum [%ld..%ld] = %.8f\n",
           rank, size, getenv("HOSTNAME") ? getenv("HOSTNAME") : "unknown",
           start, end, partial);

    MPI_Finalize();
    return 0;
}
CSRC

mpicc -O2 -o /tmp/mpi_demo_${SLURM_JOB_ID} /tmp/mpi_demo_${SLURM_JOB_ID}.c
srun /tmp/mpi_demo_${SLURM_JOB_ID}
rm -f /tmp/mpi_demo_${SLURM_JOB_ID}{,.c}
