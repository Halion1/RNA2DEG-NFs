include { FASTQC }        from '../../modules/local/fastqc/main'
include { FASTP }         from '../../modules/local/fastp/main'
include { STAR_ALIGN }    from '../../modules/local/star_align/main'
include { FEATURECOUNTS } from '../../modules/local/featurecounts/main'

workflow DEG_PREPROCESSING {

    take:
    samplesheet_csv
    index
    gtf

    main:
    fastq_ch = samplesheet_csv
        .splitCsv(header: true, sep: ",")
        .map { row ->
            tuple(
                row.id,
                row.name1,
                file(row.fastq1),
                row.name2,
                file(row.fastq2)
            )
        }

    raw_qc_ch = FASTQC(fastq_ch)

    trimmed_ch = FASTP(fastq_ch)

    trimmed_fastq_ch = trimmed_ch.out.trimmed_reads.map { id, sample1, fq1, sample2, fq2 ->
        tuple(id, sample1, fq1, sample2, fq2)
    }

    trimmed_qc_ch = FASTQC(trimmed_fastq_ch)

    aligned_ch = STAR_ALIGN(trimmed_fastq_ch, index, gtf)

    counts_ch = FEATURECOUNTS(aligned_ch.out.aligned_bam, gtf)

    emit:
    parsed_fastq   = fastq_ch
    raw_qc         = raw_qc_ch.out.qc_reports
    trimmed_reads  = trimmed_ch.out.trimmed_reads
    trimmed_qc     = trimmed_qc_ch.out.qc_reports
    aligned_bam    = aligned_ch.out.aligned_bam
    counts_table   = counts_ch.out.counts_table
}