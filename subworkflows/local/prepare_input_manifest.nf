include { MD5_AND_PATH }      from '../../modules/local/md5_and_path/main'
include { BUILD_SAMPLESHEET } from '../../modules/local/build_samplesheet/main'

workflow PREPARE_INPUT_MANIFEST {

    take:
    samples_dir
    mode
    samplesheet_script

    main:
    md5_ch = MD5_AND_PATH(samples_dir)
    samplesheet_ch = BUILD_SAMPLESHEET(md5_ch.out.md5_table, mode, samplesheet_script)

    emit:
    md5_table   = md5_ch.out.md5_table
    samplesheet = samplesheet_ch.out.samplesheet
}