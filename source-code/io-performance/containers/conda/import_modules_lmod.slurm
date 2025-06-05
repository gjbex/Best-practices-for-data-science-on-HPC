#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --cluster=wice
#SBATCH --partition=gpu_h100
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time 00:30:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=geertjan.bex@uhasselt.be

start_time=$(date +%s)

module purge &> /dev/null
module load SciPy-bundle/2023.07-gfbf-2023a
module load matplotlib/3.7.2-gfbf-2023a
module load scikit-learn/1.3.1-gfbf-2023a
module load PyTorch-bundle/2.1.2-foss-2023a-CUDA-12.1.1
module load TensorFlow/2.15.1-foss-2023a-CUDA-12.1.1

python import_modules.py 2> /dev/null

end_time=$(date +%s)

printf "Total time: %d" $(( $end_time - $start_time ))
