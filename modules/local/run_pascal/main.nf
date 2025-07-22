process RUN_PASCAL {

    container 'jungwooseok/mea_pascal:1.1' // TODO: add to biocontainers (this contains fixed PascalX)
    label "process_low"

    input:
    path geneScoreFile
    path moduleFile
    path goFile

    output:
    path("pascalOutput/*"), emit: pascaloutput
    path(geneScoreFile),    emit: genescorefile
    path(goFile),           emit: gofile
    path("versions.yml"),   emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    python3 ${moduleDir}/bin/runPascal.py \
        ${geneScoreFile} \
        ${moduleFile} \
        "pascalOutput/" \
        ${params.pipeline} \
        ${params.trait}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version)
        PascalX: \$(python3 -c "import PascalX; print(PascalX.__version__)")
    END_VERSIONS
    """
}
