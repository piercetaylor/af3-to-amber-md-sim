#!/bin/bash
#SBATCH --job-name=NPT_MUT
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --chdir=/path/to/your/simulation
#SBATCH --output=/path/to/your/simulation/logs/npt_MUT_%j.log

module load amber/24

pmemd.cuda -O \
    -i inputs/npt.in \
    -o MUT/npt_MUT.out \
    -p MUT/PROTEIN_MUT.prmtop \
    -c MUT/nvt_MUT.rst7 \
    -r MUT/npt_MUT.rst7 \
    -x MUT/npt_MUT.nc \
    -ref MUT/nvt_MUT.rst7
