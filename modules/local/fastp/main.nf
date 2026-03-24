process FASTP {

    tag "${id}"
    label 'fastq_prof'
    conda "${projectDir}/environments/deg_preprocessing.yml"

    input:
    tuple val(id), val(sample1), path(seqfastq1), val(sample2), path(seqfastq2)

    output:
    tuple val(id), val(sample1), path("${sample1}_FP.fastq.gz"), val(sample2), path("${sample2}_RP.fastq.gz"), emit: trimmed_reads

    script:
    """
    set -euo pipefail

    fastp -w ${task.cpus} \
        --in1 "${seqfastq1}" \
        --in2 "${seqfastq2}" \
        --out1 "${sample1}_FP.fastq.gz" \
        --out2 "${sample2}_RP.fastq.gz"
    """
}