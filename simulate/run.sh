#!/bin/bash
#SBATCH -c 128
#SBATCH --mem=24576
#SBATCH --mail-type=ALL
#SBATCH -t 24:00:00

julia --project=~/QNet-MTP/simulate --threads=auto ~/QNet-MTP/simulate/simulate.jl