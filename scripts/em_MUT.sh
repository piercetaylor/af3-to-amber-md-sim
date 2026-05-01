#!/bin/bash
#SBATCH --job-name=EM_MUT
#SBATCH --partition=general
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=4:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/em_MUT_%j.log

module load amber/24

pmemd -O \
    -i inputs/em.in \
    -o MUT/em_MUT.out \
    -p MUT/PROTEIN_MUT.prmtop \
    -c MUT/PROTEIN_MUT.inpcrd \
    -r MUT/em_MUT.rst7 \
    -ref MUT/PROTEIN_MUT.inpcrd
