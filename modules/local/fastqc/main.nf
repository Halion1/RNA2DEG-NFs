process FASTQC {

    tag "${id}"
    label 'fastq_prof'
    conda "${projectDir}/environments/deg_preprocessing.yml"

    input:
    tuple val(id), val(sample1), path(seqfastq1), val(sample2), path(seqfastq2)

    output:
    tuple val(id), path("*_fastqc.html"), path("*_fastqc.zip"), emit: qc_reports

    script:
    """
    set -euo pipefail

    fastqc -t ${task.cpus} -f fastq "${seqfastq1}" "${seqfastq2}"
    """
}