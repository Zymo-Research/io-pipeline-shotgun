process FASTQC {
    tag "$meta.id"
    // label 'process_low'

    maxForks 5
    cpus 4
    memory { meta.single_end ? (reads.size() < 4.GB ? 4.GB * task.attempt: 8.GB * task.attempt) :  16.GB }

    conda "bioconda::fastqc=0.12.9"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0' :
        'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip") , emit: zip
    path  "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (meta.single_end) {
        """
        [ -f ${prefix}_R1.fastq.gz ] || ln -s ${reads[0]} ${prefix}_R1.fastq.gz

        fastqc $args --threads $task.cpus ${prefix}_R1.fastq.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
        END_VERSIONS
        """
    } else {
        """
        [ -f ${prefix}_R1.fastq.gz ] || ln -s ${reads[0]} ${prefix}_R1.fastq.gz
        [ -f ${prefix}_R2.fastq.gz ] || ln -s ${reads[1]} ${prefix}_R2.fastq.gz

        fastqc $args --threads $task.cpus ${prefix}_R1.fastq.gz ${prefix}_R2.fastq.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
        END_VERSIONS
        """
    }
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.html
    touch ${prefix}.zip

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
    END_VERSIONS
    """
}
