nextflow.enable.dsl=2

include { FETCH_INPUT_DATA }         from '../subworkflows/local/fetch_input_data.nf'
include { PREPARE_INPUT_MANIFEST }   from '../subworkflows/local/prepare_input_manifest.nf'
include { DEG_PREPROCESSING }        from '../subworkflows/local/deg_preprocessing.nf'

workflow RNA2DEG {

    take:
    source_input
    samples_dir
    mode
    samplesheet_script
    index
    gtf

    main:
    /*
     * 1. Download or ingest input data
     *    This subworkflow handles:
     *    - sra_open
     *    - sra_restricted
     *    - gdc
     *
     *    Important:
     *    the practical assumption in your current design is that all downloaded
     *    files end up under one common parent directory: samples_dir
     */
    FETCH_INPUT_DATA(source_input)

    /*
     * 2. Build the manifest / samplesheet from the common samples directory
     */
    manifest_ch = PREPARE_INPUT_MANIFEST(
        samples_dir,
        mode,
        samplesheet_script
    )

    /*
     * 3. Run DEG preprocessing from the generated samplesheet
     *    This includes:
     *    - raw FastQC
     *    - fastp
     *    - trimmed FastQC
     *    - STAR
     *    - featureCounts
     */
    deg_ch = DEG_PREPROCESSING(
        manifest_ch.out.samplesheet,
        index,
        gtf
    )

    emit:
    /*
     * From FETCH_INPUT_DATA
     */
    downloaded_reads = FETCH_INPUT_DATA.out.downloaded_reads
    source_metadata  = FETCH_INPUT_DATA.out.source_metadata
    download_reports = FETCH_INPUT_DATA.out.download_reports

    /*
     * From PREPARE_INPUT_MANIFEST
     */
    md5_table        = manifest_ch.out.md5_table
    samplesheet      = manifest_ch.out.samplesheet

    /*
     * From DEG_PREPROCESSING
     */
    parsed_fastq     = deg_ch.out.parsed_fastq
    raw_qc           = deg_ch.out.raw_qc
    trimmed_reads    = deg_ch.out.trimmed_reads
    trimmed_qc       = deg_ch.out.trimmed_qc
    aligned_bam      = deg_ch.out.aligned_bam
    counts_table     = deg_ch.out.counts_table
}