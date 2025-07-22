process GO_ANALYSIS {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/3f/3f66c80d58883f9f294b871ef45967430ff19bae174f71bb902c3eca3ef805ec/data' :
        'community.wave.seqera.io/library/r-optparse_r-stringr_r-webgestaltr:8176ac8478d07225' }"
    label "process_low"

    input:
    path masterSummarySlice
    path sigModuleDir
    path goFile

    output:
    path(masterSummarySlice),   emit: mastersummaryslice
    path("${params.GO_summaries_path}/${params.trait}/GO_summaries_${goFile.baseName.split('_')[2]}_${goFile.baseName.split('_')[3]}/"),   emit: gosummaries
    path(goFile),               emit: gofile
    path("${params.GO_summaries_path}/"), emit: gosummaries_path
    path("versions.yml"),       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def oraSummaryDir = "${params.GO_summaries_path}/${params.trait}/GO_summaries_${goFile.baseName.split('_')[2]}_${goFile.baseName.split('_')[3]}/"
    """
    Rscript ${moduleDir}/bin/ORA_cmd.R --sigModuleDir ${sigModuleDir} --backGroundGenesFile ${goFile} \
        --summaryRoot "${oraSummaryDir}" --reportRoot "GO_reports/"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$(Rscript -e "cat(R.version.string)")
        WebGestaltR: \$(Rscript -e "suppressMessages(library('WebGestaltR')); cat(as.character(packageVersion('WebGestaltR')))")
        stringr: \$(Rscript -e "suppressMessages(library('stringr')); cat(as.character(packageVersion('stringr')))")
        optparse: \$(Rscript -e "suppressMessages(library('optparse')); cat(as.character(packageVersion('optparse')))")
    END_VERSIONS
    """
}
