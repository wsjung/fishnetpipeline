process IDENTIFY_MEA_PASSING_GENES {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/9b/9bfbfc4f5dbd4c45e3e97eec3fee1f80a30919c69610327f63dd0095119e3a2b/data' :
        'community.wave.seqera.io/library/numpy_python_scipy_pip_pandas:8ef8b8050da9963f' }"
    conda "${moduleDir}/environment.yml"
    label 'process_low'

    input:
    path or_fishnet_genes
    path trait_file
    val trait
    path(module_file, stageAs: "module/*")
    val module_name
    path(network_file, stageAs: "network/*")
    path master_summary_filtered_parsed

    output:
    path("significant_module_connections/*"),   optional: true, emit: sig_module_connections
    path("summary/*"),                          emit: fishnet_genes
    path("versions.yml"),                       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    python3 ${moduleDir}/bin/dc_no_RP_identify_mea_passing_genes.py \
        --trait ${trait} \
        --geneset_input ${trait_file} \
        --network ${module_name} \
        --summary_fishnet_genes_filepath ${or_fishnet_genes} \
        --network_connections_path ${network_file} \
        --master_summary_filtered_parsed_path ${master_summary_filtered_parsed} \
        --module_path ${module_file}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version)
        pandas: \$(python3 -c "import pandas; print(pandas.__version__)")
        numpy: \$(python3 -c "import numpy; print(numpy.__version__)")
        scipy: \$(python3 -c "import scipy; print(scipy.__version__)")
    END_VERSIONS
    """

}
