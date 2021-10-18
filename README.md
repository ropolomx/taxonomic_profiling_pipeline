# taxonomic_profiling_pipeline


This pipeline was developed using the [Snakemake worfklow management system](https://snakemake.readthedocs.io/en/stable/)

You would need to have the Snakefile, the `env` folder and its contents (YAML files with environment definition), and a table with the absolute paths for forward and reverse reads files.

To run in your computer

`snakemake --use-conda`

To run in a High Performance Computing cluster with the SGE job scheduler:

`snakemake snakemake  --cluster "qsub -V -cwd -pe smp {threads}" --use-conda`

## Introduction:
#### This workflow uses:
- fastp to remove adapters and QC
- bowtie2 to remove phiX genome reads
- kraken2 for taxonomic classification our curated BeeRoLaMa database

#### To perform this analysis:
1.	First navigate to the directory containing the read files (end in `.fastq.gz`)
2.	Ensure there is a `.tab` file (eg. `samples_new.tab`) that contains all the filenames of the read files
3.	Clone the Snakemake pipeline into the current directory
4.	Ensure the `.tab` file (containing the sample names) is specified in the `kraken_config.yaml` file
5.	Either update `samples_new.tab` to point to the raw data files (eg. add `../` before all the file names), or copy all the contents of the repository to the same folder where the samples are, i.e. `cp -r taxonomic_profiling_pipeline/* .`
6.	Copy the contents of the folder `/isilon/lacombe-rdc/users/tranlan/phiX` into the working directory folder
7.	Update names of folders that will be generated during the run by replacing all instances of `beerolama_mpa_shallow` in the Snakefile to something like `cra_kraken2`
8.	Activate the conda environment containing Snakemake: `conda activate Snakemake`
9.	Perform a dry run: `snakemake –nr`
  - All green messages is good, errors will show up in red
10.	Run the workflow: `snakemake  --cluster "qsub -V -cwd -pe smp {threads}" --use-conda -j <number_of_jobs>`
  - Replace `<number_of_jobs>` with the number of `.fastq.gz` files divided by 2
