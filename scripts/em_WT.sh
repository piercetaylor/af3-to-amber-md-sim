#!/bin/bash
#SBATCH --job-name=EM_WT
#SBATCH --partition=general
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=4:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/em_WT_%j.log

module load amber/24

pmemd -O \
    -i inputs/em.in \
    -o WT/em_WT.out \
    -p WT/PROTEIN_WT.prmtop \
    -c WT/PROTEIN_WT.inpcrd \
    -r WT/em_WT.rst7 \
    -ref WT/PROTEIN_WT.inpcrd
