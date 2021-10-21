# taxonomic_profiling_pipeline


This pipeline was developed using the [Snakemake worfklow management system](https://snakemake.readthedocs.io/en/stable/)

You would need to have the Snakefile, the `env` folder and its contents (YAML files with environment definition), and a table with the absolute paths for forward and reverse reads files specified in `config.yaml`.

To run in your computer

`snakemake --use-conda`

To run in a High Performance Computing cluster with the SGE job scheduler:

`snakemake --cluster "qsub -V -cwd -pe smp {threads}" --use-conda`

### Config options:
The following attributes can be changed/specified in the `config.yaml` file:  
- Input sample sheet file path  
- The directory to which output is written (default `results`)  
- The database used for Kraken classification  
- Flags to specify whether you want to keep certain intermediate/output files:  
    - Fastp processed read files - will likely be large and unneeded upon pipeline completion
    - Bowtie2 processed read files - will likely be large and unneeded upon pipeline completion
    - Kraken classification files - will likely be large and kraken reports are often sufficient
    - Fastqc reports - not large, but multiqc report summarizes fastqc reports

## Introduction:
### Requirements:
This workflow requires the [Conda package manager](https://docs.conda.io/en/latest/), which handles the installation of tools and their dependencies.
- For general installation instructions, see the [Conda installation documentation](https://conda.io/projects/conda/en/latest/user-guide/install/index.html).
- For installation on AAFC Biocluster, see the [Redmine documentation](https://redmine.biodiversity.agr.gc.ca/projects/biocluster/wiki/Installing_Conda) (requires AAFC VPN), or see instructions in the appendix below.

This workflow is written in, and therefore requires, Snakemake, which can be installed using Conda. Once Conda is installed, the following command will create a Conda environment with Snakemake (and an additional dependency, [Mamba](https://github.com/mamba-org/mamba)):
- `conda create -n <env-name> -c bioconda -c conda-forge snakemake mamba`

replacing `<env-name>` with a name of your choice.

### This workflow uses:
- [fastp](https://github.com/OpenGene/fastp) to remove adapters and QC
- [bowtie2](https://github.com/BenLangmead/bowtie2) to remove phiX genome reads
- [kraken2](https://github.com/DerrickWood/kraken2/wiki) for taxonomic classification with our curated BeeRoLaMa database
- [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) for quality control for individual sequence files
- [multiqc](https://github.com/ewels/MultiQC) for summary of all fastqc quality control reports
- [krona](https://github.com/marbl/Krona/wiki) for taxonomy result visualization


## To perform this analysis:
1.	First navigate to the directory containing the read files (end in `.fastq.gz`)
2.	Ensure there is a `.tab` file (eg. `samples_new.tab`) that contains all the filenames of the read files
3.	Clone the Snakemake pipeline into the current directory
4.	Ensure the `.tab` file (containing the sample names) is specified in the `config.yaml` file
5.	Either update `samples_new.tab` to point to the raw data files (eg. add `../` before all the file names), or copy all the contents of the repository to the same folder where the samples are, eg. `cp -r taxonomic_profiling_pipeline/* .`
6.	Copy an indexed phiX genome into the directory where the Snakemake will be run. 
    - `cp /isilon/lacombe-rdc/users/tranlan/phiX/* .` if on AAFC Biocluster
    - **(TODO: generalize phiX instructions)**
7.	Update names of folders that will be generated during the run by replacing all instances of `beerolama_mpa_shallow` in the Snakefile to something like `cra_kraken2`
8.	Activate the conda environment containing Snakemake: eg. `conda activate Snakemake`
9.	Perform a dry run: `snakemake –nr`
    - All green messages is good, errors will show up in red
10.	Run the workflow: `snakemake  --cluster "qsub -V -cwd -pe smp {threads}" --use-conda -j <number_of_jobs> [--latency-wait <seconds>]`
    - Replace `<number_of_jobs>` with the number of `.fastq.gz` files divided by 2
    - The `--latency-wait` is optional. The Krona rule has raised a false error in which it says the output file has not produced when it actually has. A wait of 60s has prevented this error.

---

#### APPENDIX: Conda installation on Biocluster:
1.  Connect to the [Biocluster](https://redmine.biodiversity.agr.gc.ca/projects/biocluster/wiki/Connecting_to_the_biocluster) (VPN link)
2.  Run the following commands from your home directory:  
3. `wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh`  
4. `sh Miniconda3-latest-Linux-x86_64.sh`  
5. You will be guided through a command line based installation wizard:  
    - Press `<Enter>` to continue  
    - Press `q` to close the license or `<Enter>` to scroll through it until you've read it all  
    - Type `yes` to accept the license, then presse `<Enter>`  
    - Prepending the miniconda install location is no longer the recommended way to enable Conda, so type `no` and press `<Enter>`  
6. At this point, Conda is installed in your home directory, but if you try running it now, you'll get an error. This is because you have not told the command line interpreter that you want Conda enabled in your path. You can do this by running the following command:  
    - `source ~/miniconda3/etc/profile.d/conda.sh`  
    - This command tells the command line interpreter to run the Conda _source script_, which enables the `conda` command for your environment. You will likely want to run this command every time you connect to the Biocluster, so you are encouraged to edit your `~/.bashrc file`, and add that command to the end of the file.  
7. Installation is complete, but you should ensure that it is up to the latest version. You can do this by running `conda update conda`  
8. Finally, configure some conda channels by running the following commands  
    > conda config --add channels defaults  
    > conda config --add channels bioconda  
    > conda config --add channels conda-forge
