process POSTPROCESS_PASCAL_OUTPUT {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-9d836da785124bb367cbe6fbfc00dddd2107a4da:b033d6a4ea3a42a6f5121a82b262800f1219b382-0' :
        'quay.io/biocontainers/mulled-v2-9d836da785124bb367cbe6fbfc00dddd2107a4da:b033d6a4ea3a42a6f5121a82b262800f1219b382-0' }"
    label "process_low"
    publishDir "./results/${params.pipeline}/", pattern: "significantModules/*", mode: 'copy'

    input:
    path(pascalOutputFile)
    path(geneScoreFilePascalInput) // used to decide number of tests
    path(goFile)

    output:
    path("masterSummaryPiece/master_summary_slice_*"),  emit:summaryslice
    path("significantModules/"),                        emit:sigmodules
    path(goFile),                                       emit:gofile

    """
    python3 ${projectDir}/bin/processPascalOutput.py \
        ${pascalOutputFile} \
        ${params.bonferroni_alpha} \
        "masterSummaryPiece/" \
        ${geneScoreFilePascalInput} \
        "significantModules/" \
        ${params.numTests}
    """
}
