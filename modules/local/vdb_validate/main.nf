process VDB_VALIDATE {

    tag "${accession}"
    label 'validate_prof'
    conda "${projectDir}/environments/batch_down_env.yml"
    publishDir params.download_dir, mode: 'copy'

    input:
    tuple val(accession), path(accession_sra)

    output:
    tuple val(accession), path("validateout_${accession}.txt"), emit: validation_report

    script:
    """
    vdb-validate "${accession_sra}" > "validateout_${accession}.txt"
    """
}