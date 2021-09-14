# taxonomic_profiling_pipeline


This pipeline was developed using the [Snakemake worfklow management system](https://snakemake.readthedocs.io/en/stable/)

You would need to have the Snakefile, the `env` folder and its contents (YAML files with environment definition), and a table with the absolute paths for forward and reverse reads files.

To run in your computer

`snakemake --use-conda`

To run in a High Performance Computing cluster with the SGE job scheduler:

`snakemake snakemake  --cluster "qsub -V -cwd -pe smp {threads}" --use-conda`
