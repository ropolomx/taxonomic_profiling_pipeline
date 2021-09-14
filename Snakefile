import pandas as pd

configfile: 'kraken_config.yaml'

SAMPLE = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)

KRAKEN_CLASSIFICATIONS = expand('beerolama_mpa_shallow/{sample}_classification.txt', sample = SAMPLE.index)

KRAKEN_REPORTS = expand('beerolama_mpa_shallow/{sample}_report.txt', sample=SAMPLE.index)

rule all:
    input:
        KRAKEN_CLASSIFICATIONS, KRAKEN_REPORTS

rule fastp:
    input:
        fwd=lambda wildcards: SAMPLE.loc[wildcards.sample, 'forward'],
        rev=lambda wildcards: SAMPLE.loc[wildcards.sample, 'reverse']
    output:
        fwd='fastp_shallow/{sample}_fastp_R1.fastq.gz',
        rev='fastp_shallow/{sample}_fastp_R2.fastq.gz'
    conda:
        'envs/fastp.yaml'
    shell:
        'fastp -i {input.fwd} -I {input.rev} -o {output.fwd} -O {output.rev}'

rule bowtie2:
    input:
        fwd='fastp_shallow/{sample}_fastp_R1.fastq.gz',
        rev='fastp_shallow/{sample}_fastp_R2.fastq.gz'
    output:
        fwd='{sample}_unmapped.fastq.1.gz',
        rev='{sample}_unmapped.fastq.2.gz'
    conda:
        'envs/bowtie2.yaml'
    log:
        'logs/bowtie2/{sample}.log'
    shell:
        '(bowtie2 -p 8 -x phiX -1 {input.fwd} -2 {input.rev} --un-conc-gz {wildcards.sample}_unmapped.fastq.gz) 2> {log}'

rule kraken2:
    input:
        fwd='{sample}_unmapped.fastq.1.gz',
        rev='{sample}_unmapped.fastq.2.gz'
    params:
        thread = 16,
        confidence = 0,
        base_qual = 0
    output:
        kraken_class = 'beerolama_mpa_shallow/{sample}_classification.txt',
        kraken_report = 'beerolama_mpa_shallow/{sample}_report.txt'
    conda:
        'envs/kraken2.yaml'
    shell:
        "kraken2 "
        "--db /isilon/lethbridge-rdc/users/ortegapoloro/kraken2db/beerolama_v1 "
        "--threads {params.thread} "
        "--output {output.kraken_class} "
        "--confidence {params.confidence} "
        "--minimum-base-quality {params.base_qual} "
        "--report {output.kraken_report} "
        #"--memory-mapping "
        "--use-mpa-style "
        "--paired "
        "--use-names "
        "--gzip-compressed "
        "{input.fwd} {input.rev}"
