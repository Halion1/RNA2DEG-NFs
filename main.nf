nextflow.enable.dsl=2

include { RNA2DEG } from './workflows/rna2deg.nf'

workflow {

    /*
     * Resolve the input source depending on the selected source type.
     *
     * sra_open / sra_restricted:
     *   expect an accession file
     *
     * gdc:
     *   expect a manifest file
     */
    def source_input = null

    if (params.source in ['sra_open', 'sra_restricted']) {
        if (!params.accession_file) {
            error "For params.source='${params.source}', you must provide --accession_file"
        }
        source_input = file(params.accession_file)
    }
    else if (params.source == 'gdc') {
        if (!params.manifest_file) {
            error "For params.source='gdc', you must provide --manifest_file"
        }
        source_input = file(params.manifest_file)
    }
    else {
        error "Unsupported --source value: ${params.source}. Use: sra_open, sra_restricted, or gdc"
    }

    /*
     * Required shared inputs
     */
    if (!params.samples_dir) {
        error "Missing required parameter: --samples_dir"
    }

    if (!params.mode) {
        error "Missing required parameter: --mode"
    }

    if (!params.samplesheet_script_ch) {
        error "Missing required parameter: --samplesheet_script_ch"
    }

    if (!params.index) {
        error "Missing required parameter: --index"
    }

    if (!params.gtf) {
        error "Missing required parameter: --gtf"
    }

    /*
     * Launch the top-level workflow
     */
    RNA2DEG(
        source_input,
        file(params.samples_dir),
        params.mode,
        file(params.samplesheet_script_ch),
        file(params.index),
        file(params.gtf)
    )
}