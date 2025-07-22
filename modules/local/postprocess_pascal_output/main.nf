process POSTPROCESS_PASCAL_OUTPUT {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-9d836da785124bb367cbe6fbfc00dddd2107a4da:b033d6a4ea3a42a6f5121a82b262800f1219b382-0' :
        'quay.io/biocontainers/mulled-v2-9d836da785124bb367cbe6fbfc00dddd2107a4da:b033d6a4ea3a42a6f5121a82b262800f1219b382-0' }"
    label "process_low"

    input:
    path pascalOutputFile
    path geneScoreFilePascalInput   // used to decide number of tests
    path goFile

    output:
    path("masterSummaryPiece/master_summary_slice_*"),  emit: summaryslice
    path("significantModules/"),                        emit: sigmodules
    path(goFile),                                       emit: gofile
    path("versions.yml"),                               emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    python3 ${moduleDir}/bin/processPascalOutput.py \
        ${pascalOutputFile} \
        ${params.bonferroni_alpha} \
        "masterSummaryPiece/" \
        ${geneScoreFilePascalInput} \
        "significantModules/" \
        ${params.numTests}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version)
        pandas: \$(python3 -c "import pandas; print(pandas.__version__)")
        statsmodels: \$(python3 -c "import statsmodels; print(statsmodels.__version__)")
    END_VERSIONS
    """
}
