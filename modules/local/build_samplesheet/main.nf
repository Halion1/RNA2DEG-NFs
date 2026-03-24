process BUILD_SAMPLESHEET {

    tag "${mode}"
    label 'csv_prof'
    conda "${projectDir}/environments/metadata_env.yml"

    input:
    path md5_table
    val  mode
    path samplesheet_script

    output:
    path "samplesheet_basic.csv", emit: samplesheet

    script:
    """
    set -euo pipefail

    python3 "${samplesheet_script}" \
        --md5list "${md5_table}" \
        --mode "${mode}" \
        --out "samplesheet_basic.csv"

    test -s samplesheet_basic.csv
    """
}