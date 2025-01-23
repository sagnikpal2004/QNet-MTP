#!/bin/bash
#SBATCH -c 16
#SBATCH --mem=8192
#SBATCH --mail-type=ALL
#SBATCH -t 24:00:00

export JULIA_NUM_THREADS=16

julia --project=~/QNet-MTP/ ~/QNet-MTP/test/simulate.jl