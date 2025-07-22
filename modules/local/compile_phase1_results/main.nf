process COMPILE_PHASE1_RESULTS {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/9b/9bfbfc4f5dbd4c45e3e97eec3fee1f80a30919c69610327f63dd0095119e3a2b/data' :
        'community.wave.seqera.io/library/numpy_python_scipy_pip_pandas:8ef8b8050da9963f' }"
    conda "${moduleDir}/environment.yml"
    label "process_low"

    input:
    path summaries                  // path to summaries directory

    output:
    path("./master_summary_${params.pipeline}.csv"),    emit: master_summary_file        // path to master summary file
    path("versions.yml"),                               emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    python3 ${moduleDir}/bin/compile_phase1_results.py \
        --dirPath ${summaries} \
        --identifier ${params.pipeline} \
        --output .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version)
        pandas: \$(python3 -c "import pandas; print(pandas.__version__)")
    END_VERSIONS
    """
}
