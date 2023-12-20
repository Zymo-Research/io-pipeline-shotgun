process SOURMASH_PREFETCH {
    tag "$meta.id"
    label 'process_high_memory'

    if (params.ignore_failed_samples) {
        errorStrategy { task.attempt>1 ? 'ignore' : 'retry' }
    }

    input:
    tuple val(meta), path(sketch), path(sketch_log)
    path "sourmash_database/*"

    output:
    tuple val(meta), path('*_fastgather.csv'), emit: picklist
    path "versions.yml", emit: versions 
    path "*.log"

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"    
    """
    DB=`find -L "sourmash_database" -name "*${params.sourmash_kmersize}.txt"`
    sourmash scripts fastgather $sketch \$DB -k ${params.sourmash_kmersize} -o ${prefix}_fastgather.csv>${prefix}_fastgather.log
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(sourmash --version | sed 's/sourmash //')  
    END_VERSIONS

    """
}

