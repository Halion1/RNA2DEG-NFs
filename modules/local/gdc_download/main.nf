process GDC_DOWNLOAD {

    tag "${accession}"
    label 'gdc_prof'
    conda "${projectDir}/environments/gdc_download.yml"

    input:
    val accession

    output:
    tuple val(accession), path("${accession}"), emit: gdc_data

    script:
    """
    gdc-client download -t ${params.gdc_token} ${accession}

    if [ ! -d "${accession}" ]; then
        echo "ERROR: Expected GDC download directory ${accession} not found" >&2
        exit 1
    fi
    """
}