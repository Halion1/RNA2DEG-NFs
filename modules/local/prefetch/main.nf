process PREFETCH {

    tag "${accession}"
    label 'prefetch_prof'
    conda "${projectDir}/environments/batch_down_env.yml"

    input:
    val accession

    output:
    tuple val(accession), path("${accession}.sra"), emit: sra_file

    script:
    def ngc_arg = params.ngc_key ? "--ngc ${params.ngc_key}" : ""
    """
    prefetch ${accession} \
        -o "${accession}.sra" \
        --max-size ${params.prefetch_max_size ?: '50g'} \
        -vvv \
        ${ngc_arg}
    """
}