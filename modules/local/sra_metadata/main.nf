process SRA_METADATA {

    tag "${accession}"
    label 'metadata_prof'
    conda 'batch_down_env.yml'

    input:
    val accession

    output:
    tuple val(accession), path("metadata_${accession}.csv"), emit: metadata_csv

    script:
    def metadata_cmd = (params.source == 'sra_open') \
        ? "esummary -db sra -id \"${accession}\" -format runinfo" \
        : "esearch -db sra -query \"${accession}\" | efetch -format runinfo"

    """
    ${metadata_cmd} > metadata_${accession}.csv
    """
}