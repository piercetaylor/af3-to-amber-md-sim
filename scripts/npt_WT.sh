#!/bin/bash
#SBATCH --job-name=NPT_WT
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/npt_WT_%j.log

module load amber/24

pmemd.cuda -O \
    -i inputs/npt.in \
    -o WT/npt_WT.out \
    -p WT/PROTEIN_WT.prmtop \
    -c WT/nvt_WT.rst7 \
    -r WT/npt_WT.rst7 \
    -x WT/npt_WT.nc \
    -ref WT/nvt_WT.rst7
