#!/bin/bash
#SBATCH --job-name=NVT_WT
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/nvt_WT_%j.log

module load amber/24

pmemd.cuda -O \
    -i inputs/nvt.in \
    -o WT/nvt_WT.out \
    -p WT/PROTEIN_WT.prmtop \
    -c WT/em_WT.rst7 \
    -r WT/nvt_WT.rst7 \
    -x WT/nvt_WT.nc \
    -ref WT/em_WT.rst7
