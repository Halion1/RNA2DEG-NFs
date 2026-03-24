process VDB_VALIDATE {

    tag "${accession}"
    label 'validate_prof'
    conda 'batch_down_env.yml'

    input:
    tuple val(accession), path(accession_sra)

    output:
    tuple val(accession), path("validateout_${accession}.txt"), emit: validation_report

    script:
    """
    vdb-validate "${accession_sra}" > "validateout_${accession}.txt"
    """
}