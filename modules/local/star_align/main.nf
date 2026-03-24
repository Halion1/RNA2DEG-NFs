process STAR_ALIGN {

    tag "${id}"
    label 'fastqstar_prof'
    conda "${projectDir}/environments/deg_preprocessing.yml"
    publishDir params.bam_dir, mode: 'copy'

    input:
    tuple val(id), val(sample1), path(seqfastq1), val(sample2), path(seqfastq2)
    path index
    path gtf

    output:
    tuple val(id), path("${id}_Aligned.sortedByCoord.out.bam"), emit: aligned_bam

    script:
    """
    set -euo pipefail

    STAR --runThreadN ${task.cpus} \
        --genomeDir "${index}" \
        --readFilesIn "${seqfastq1}" "${seqfastq2}" \
        --readFilesCommand zcat \
        --sjdbGTFfile "${gtf}" \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMunmapped Within \
        --outFileNamePrefix "${id}_"
    """
}