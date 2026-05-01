#!/bin/bash
#SBATCH --job-name=PROD_MUT
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/prod_MUT_%j.log

module load amber/24

pmemd.cuda -O \
    -i inputs/prod.in \
    -o MUT/prod_MUT.out \
    -p MUT/PROTEIN_MUT.prmtop \
    -c MUT/npt_MUT.rst7 \
    -r MUT/prod_MUT.rst7 \
    -x MUT/prod_MUT.nc
