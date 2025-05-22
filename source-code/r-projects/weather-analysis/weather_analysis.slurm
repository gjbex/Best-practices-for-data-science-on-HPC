#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --time=00:02:00
#SBATCH --cluster=wice

# first clean up your environment, then load R
module purge &> /dev/null
module load R/4.4.0-gfbf-2023a

# define output directory and create it if it does not exist
OUTDIR="output"
mkdir -p $OUTDIR

# define the quantity to analyse
QUANTITY="tempmax"

Rscript ./weather_analysis.R  \
    --input data/London.csv   \
    --quantity "$QUANTITY"    \
    --output $OUTDIR/$QUANTITY.csv
