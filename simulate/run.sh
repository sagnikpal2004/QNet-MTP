#!/bin/bash
#SBATCH -c 2
#SBATCH --mem=2G
#SBATCH --mail-type=ALL
#SBATCH -t 24:00:00

julia --project=~/QNet-MTP/simulate --threads=auto ~/QNet-MTP/simulate/simulate.jl