include { PREFETCH }      from '../../modules/local/prefetch/main'
include { VDB_VALIDATE }  from '../../modules/local/vdb_validate/main'
include { FASTERQ_DUMP }  from '../../modules/local/fasterq_dump/main'
include { SRA_METADATA }  from '../../modules/local/sra_metadata/main'
include { GDC_DOWNLOAD }  from '../../modules/local/gdc_download/main'

workflow FETCH_INPUT_DATA {

    take:
    source_input

    main:

    if( params.source in ['sra_open', 'sra_restricted'] ) {

        sra_ch = source_input
            .splitText()
            .map { it.trim() }
            .filter { it }

        metadata_ch = SRA_METADATA(sra_ch)
        sra_file_ch = PREFETCH(sra_ch)
        validation_ch = VDB_VALIDATE(sra_file_ch.out.sra_file)
        fastq_dir_ch = FASTERQ_DUMP(metadata_ch.out.metadata_csv.join(sra_file_ch.out.sra_file))

        downloaded_reads = fastq_dir_ch.out.fastq_dir
        source_metadata  = metadata_ch.out.metadata_csv
        download_reports = validation_ch.out.validation_report

    } else if( params.source == 'gdc' ) {

        gdc_id_ch = source_input
            .splitCsv(header: true, sep: '\t')
            .map { row -> row.id }

        gdc_data_ch = GDC_DOWNLOAD(gdc_id_ch)

        downloaded_reads = gdc_data_ch.out.gdc_data
        source_metadata  = Channel.empty()
        download_reports = Channel.empty()

    } else {
        error "Unsupported params.source: ${params.source}. Use sra_open, sra_restricted, or gdc."
    }

    emit:
    downloaded_reads
    source_metadata
    download_reports
}