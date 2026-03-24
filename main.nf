nextflow.enable.dsl=2

include { RNA2DEG } from './workflows/rna2deg.nf'

workflow {
        RNA2DEG(
        params.input
    )

}