#!/bin/bash
#SBATCH -c 16
#SBATCH --mem=8192
#SBATCH --mail-type=ALL
#SBATCH -t 24:00:00

julia --project=~/QNet-MTP/ --threads=auto ~/QNet-MTP/test/simulate.jl