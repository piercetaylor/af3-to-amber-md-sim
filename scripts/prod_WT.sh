#!/bin/bash
#SBATCH --job-name=PROD_WT
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/prod_WT_%j.log

module load amber/24

pmemd.cuda -O \
    -i inputs/prod.in \
    -o WT/prod_WT.out \
    -p WT/PROTEIN_WT.prmtop \
    -c WT/npt_WT.rst7 \
    -r WT/prod_WT.rst7 \
    -x WT/prod_WT.nc
