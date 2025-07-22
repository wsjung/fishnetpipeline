process GENERATE_OR_STATISTICS_DEFAULT {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/9b/9bfbfc4f5dbd4c45e3e97eec3fee1f80a30919c69610327f63dd0095119e3a2b/data' :
        'community.wave.seqera.io/library/numpy_python_scipy_pip_pandas:8ef8b8050da9963f' }"
    conda "${moduleDir}/environment.yml"
    label 'process_low'

    input:
    tuple   val(trait), \
            val(module_name), \
            path(trait_file), \
            path(module_file, stageAs: "module/*"), \
            path(network_file, stageAs: "network/*"), \
            path(gosummaries_path)
    path master_summary_filtered_parsed

    output:
    path("raw/*fishnet_genes.csv"),         emit: or_fishnet_genes
    path("raw/*or_summary.csv"),            emit: or_summary
    path(trait_file),                       emit: trait_file
    val(trait),                             emit: trait
    path(module_file),                      emit: module_file
    val(module_name),                       emit: module_name
    path(network_file),                     emit: network_file
    path(master_summary_filtered_parsed),   emit: master_summary_filtered_parsed
    path("versions.yml"),                   emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    python3 ${moduleDir}/bin/dc_generate_or_statistics.py \
        --gene_set_path ${trait_file} \
        --trait ${trait} \
        --study ${params.pipeline} \
        --module_path ${module_file} \
        --network $module_name \
        --master_summary_path ${master_summary_filtered_parsed} \
        --go_path "${gosummaries_path}" \
        --output_path "raw/"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version)
        pandas: \$(python3 -c "import pandas; print(pandas.__version__)")
        numpy: \$(python3 -c "import numpy; print(numpy.__version__)")
    END_VERSIONS
    """

}
