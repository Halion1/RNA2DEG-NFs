nextflow.enable.dsl=2

workflow RNA2DEG {

    take:
    input

    main:
    log.info "Running RNA2DEG pipeline"
    log.info "Input: ${input}"

    emit:
    input
}