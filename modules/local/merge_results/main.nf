process MERGE_RESULTS {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/91/9120b0b6a534ee890f23926ee93b3a7af1a92495db74ad0205676870e18384f2/data' :
        'community.wave.seqera.io/library/pandas:1.1.5--0d8ed7c4cfeffa63' }"
    label "process_low"

    input:
    path masterSummaryPiece
    path oraSummaryDir
    path goFile

    output:
    path("summaries/*"),    emit: summaries
    path("summaries/"),     emit: summaries_path
    path("versions.yml"),   emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    python3 ${moduleDir}/bin/mergeORAandSummary.py \
        ${masterSummaryPiece} \
        ${oraSummaryDir} \
        "summaries/" \
        ${goFile}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version)
        pandas: \$(python3 -c "import pandas; print(pandas.__version__)")
    END_VERSIONS
    """
}
