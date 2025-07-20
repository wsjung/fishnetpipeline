process RUN_PASCAL {

    container 'jungwooseok/mea_pascal:1.1' // TODO: add to biocontainers (this contains fixed PascalX)
    label "process_low"
    publishDir "./results/${params.pipeline}/", pattern: "pascalOutput/*", mode: 'copy'

    input:
    path(geneScoreFile)
    path(moduleFile)
    path(goFile)

    output:
    path("pascalOutput/*"), emit: pascaloutput
    path(geneScoreFile),    emit: genescorefile
    path(goFile),           emit:gofile

    script:
    """
    python3 ${projectDir}/bin/runPascal.py \
        ${geneScoreFile} \
        ${moduleFile} \
        "pascalOutput/" \
        ${params.pipeline} \
        ${params.trait}
    """
}
