process MD5_AND_PATH {

    tag "${directory}"
    label 'md5_prof'
    conda "${projectDir}/environments/metadata_env.yml"
    publishDir params.manifest_dir, mode: 'copy'

    input:
    path directory

    output:
    path "pathandmd5.tsv", emit: md5_table

    script:
    """
    set -euo pipefail

    output_file="pathandmd5.tsv"

    find "${directory}" -type f \\( -name "*.fq.gz" -o -name "*.fastq.gz" \\) | while IFS= read -r file; do
        filename=\$(basename "\$file")
        base_name="\${filename%.fq.gz}"
        base_name="\${base_name%.fastq.gz}"
        md5=\$(md5sum "\$file" | awk '{print \$1}')
        full_path=\$(readlink -f "\$file")
        printf "%s\\t%s\\t%s\\t%s\\n" "\$filename" "\$base_name" "\$md5" "\$full_path" >> "\$output_file"
    done
    """
}