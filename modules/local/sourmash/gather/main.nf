process SOURMASH_GATHER {
    tag "$meta.id"
    // label 'process_high_memory'
    // conda 'bioconda::sourmash=4.8.4'
    // conda 'conda-forge::sourmash_plugin_branchwater'
    // container 'quay.io/biocontainers/sourmash:4.8.2--hdfd78af_0'
    if (params.ignore_failed_samples) {
        errorStrategy { task.attempt>1 ? 'ignore' : 'retry' }
    }

    input:
    tuple val(meta), path(sketch), path(sketch_log)
    path "sourmash_database/*"

    output:
    tuple val(meta), path('*_fastgather.csv'), path('*.log'), emit: picklist
    tuple val(meta), path('*with-lineages.csv'), emit: gather
    path "versions.yml", emit: versions 
    path "*.log"

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"    
    """
    DB=`find -L "sourmash_database" -name "*${params.sourmash_kmersize}.zip"`
    LINEAGE=`find -L "sourmash_database" -name "*.csv"`

    sourmash scripts fastgather $sketch \$DB -k ${params.sourmash_kmersize} -o ${prefix}_fastgather.csv 2> ${prefix}_fastgather.log
    sourmash gather $sketch \$DB --dna --ksize ${params.sourmash_kmersize} --threshold-bp ${params.sourmash_threshold_bp} -o ${prefix}_sourmashgather.csv --picklist ${prefix}_fastgather.csv:match_name:ident 2> ${prefix}_sourmashgather.log
    sourmash tax annotate -g ${prefix}_sourmashgather.csv -t \$LINEAGE 2> ${prefix}_sourmashannotate.log
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(sourmash --version | sed 's/sourmash //')
    END_VERSIONS

    """
}

