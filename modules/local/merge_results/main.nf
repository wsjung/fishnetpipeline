process MERGE_RESULTS {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.1.5' :
        'quay.io/biocontainers/pandas:1.1.5' }"
    label "process_low"
    publishDir "./results/${params.pipeline}/${params.masterSummaries_path}/", mode: 'copy'

    input:
    path(masterSummaryPiece)
    path(oraSummaryDir)
    path(goFile)

    output:
    path("summaries/*"), emit: summaries

    """
    python3 ${projectDir}/bin/mergeORAandSummary.py \
        ${masterSummaryPiece} \
        ${oraSummaryDir} \
        "summaries/" \
        ${goFile}
    """

}
