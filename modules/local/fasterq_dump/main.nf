process FASTERQ_DUMP {

    tag "${accession}"
    label 'fasterqdump_prof'
    conda "${projectDir}/environments/batch_down_env.yml"

    input:
    tuple val(accession), path(metadata_file), path(accession_sra)

    output:
    tuple val(accession), path("${accession}"), emit: fastq_dir

    script:
    """
    METADATA_FILE="${metadata_file}"
    ACCESSIONSRA="${accession_sra}"
    ACCESSION="${accession}"

    if [ ! -f "\${METADATA_FILE}" ]; then
        echo "ERROR: Metadata file not found: \${METADATA_FILE}" >&2
        exit 1
    fi

    layout=\$(awk -F',' '
        NR==1 {
            for (i=1; i<=NF; i++) if (\$i == "LibraryLayout") col=i
        }
        NR>1 {
            print \$col
            exit
        }' "\${METADATA_FILE}")

    if [ -z "\${layout}" ]; then
        echo "ERROR: Could not extract LibraryLayout from metadata file" >&2
        exit 1
    fi

    fasterq-dump "\${ACCESSIONSRA}" -O "\${ACCESSION}" --split-files -p -v

    cd "\${ACCESSION}"

    if [ "\${layout}" = "SINGLE" ]; then
        if [ -f "\${ACCESSION}.fastq" ]; then
            gzip "\${ACCESSION}.fastq"
        elif [ -f "\${ACCESSION}_1.fastq" ]; then
            gzip "\${ACCESSION}_1.fastq"
        else
            echo "ERROR: Could not find expected SINGLE-end FASTQ output" >&2
            exit 1
        fi
    else
        gzip "\${ACCESSION}_1.fastq"
        gzip "\${ACCESSION}_2.fastq"
    fi
    """
}