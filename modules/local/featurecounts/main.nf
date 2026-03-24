process FEATURECOUNTS {

    tag "${id}"
    label 'counts_prof'
    conda "${projectDir}/environments/deg_preprocessing.yml"

    input:
    tuple val(id), path(bam)
    path gtf

    output:
    tuple val(id), path("${id}_featurecounts.txt"), emit: counts_table

    script:
    """
    set -euo pipefail

    featureCounts \
        -T ${task.cpus} \
        -p \
        --countReadPairs \
        -a "${gtf}" \
        -t exon \
        -g gene_id \
        -o "${id}_featurecounts.txt" \
        "${bam}" \
        --verbose
    """
}