#!/bin/bash
#SBATCH --job-name=sosoft
#SBATCH --nodes=1 --ntasks-per-node=16
#SBATCH --time=1439
#SBATCH --partition=medium
#SBATCH --mem=32gb
#SBATCH --output=/poubelle/romagnan/logs/sosoft%j.prod.out
#SBATCH --mail-user=renaud.romagnan@obspm.fr
#SBATCH --mail-type=ALL

tcsh /obs/romagnan/taches_regulieres/rattrapage/step_by_step/pp_fits_month.csh
