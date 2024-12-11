#!/bin/bash -l

#SBATCH --account=nn8999k
#SBATCH --job-name=namd2
#SBATCH --time=05:00:00
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=350M
#SBATCH --output=%x.%j.out

set -o errexit # exit on errors
set -o nounset # treat unset variables as errors
module purge # purge loaded modules
export UCX_POSIX_USE_PROC_LINK=n # escape /proc permission error

# calculate total processes (P) and and cpus per task (PPN)
P=$(( SLURM_NTASKS_PER_NODE * SLURM_NNODES ))
PPN=$((SLURM_CPUS_PER_TASK - 1))

# Path variables
FILES=/cluster/work/support/andreeve/NAMD2/files_for_support/files
NAMD2=/cluster/work/support/andreeve/NAMD2/files_for_support/namd2_mpi_smp.sif
LIGAND=/mnt/1-2/ligand

# NAMD variables
system="solv"
cnt=0
cntmax=25
REPLICAS=16

# Run initial NAMD job
srun -n $P apptainer exec --bind  $FILES:/mnt $NAMD2 namd2 +ppn $PPN $LIGAND/equ_${system}.namd | tee equ_${system}.out > /dev/null


# Run first iteration of loop
srun -n $P apptainer exec --bind $FILES:/mnt $NAMD2 namd2 +ppn $PPN +replicas $REPLICAS $LIGAND/fep_${system}.conf --source $LIGAND/FEP_remd_relative.namd +stdout /mnt/output_${system}/%d/job${cnt}.%d.log

