
process PREPROCESS_FOR_PASCAL {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-9d836da785124bb367cbe6fbfc00dddd2107a4da:b033d6a4ea3a42a6f5121a82b262800f1219b382-0' :
        'quay.io/biocontainers/mulled-v2-9d836da785124bb367cbe6fbfc00dddd2107a4da:b033d6a4ea3a42a6f5121a82b262800f1219b382-0' }"

    label "process_low"

    input:
    path pvalFile
    path modules_path

    output:
    path("pascalInput/GS_*"),       emit: gs
    path("pascalInput/Module_*"),   emit: module
    path("pascalInput/GO_*"),       emit: go
    path("versions.yml"),           emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    python3 ${moduleDir}/bin/preProcessForPascal.py \
        ${pvalFile} \
        ${modules_path} \
        "pascalInput/" \
        ${params.pipeline} \
        ${params.trait} \
        ${params.geneColName} \
        ${params.pvalColName}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version)
        pandas: \$(python3 -c "import pandas; print(pandas.__version__)")
    END_VERSIONS
    """
}
