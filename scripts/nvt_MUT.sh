#!/bin/bash
#SBATCH --job-name=NVT_MUT
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/nvt_MUT_%j.log

module load amber/24

pmemd.cuda -O \
    -i inputs/nvt.in \
    -o MUT/nvt_MUT.out \
    -p MUT/PROTEIN_MUT.prmtop \
    -c MUT/em_MUT.rst7 \
    -r MUT/nvt_MUT.rst7 \
    -x MUT/nvt_MUT.nc \
    -ref MUT/em_MUT.rst7
