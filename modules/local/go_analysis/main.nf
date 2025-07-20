process GO_ANALYSIS {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/3f/3f66c80d58883f9f294b871ef45967430ff19bae174f71bb902c3eca3ef805ec/data' :
        'community.wave.seqera.io/library/r-optparse_r-stringr_r-webgestaltr:8176ac8478d07225' }"
    publishDir "./results/${params.pipeline}/", pattern: "${params.GO_summaries_path}/${params.trait}/*", mode: 'copy' // copy ORA results to current location.
    label "process_low"

    input:
    path(masterSummarySlice)
    path(sigModuleDir)
    path(goFile)

    output:
    path(masterSummarySlice),   emit: mastersummaryslice
    path("${params.GO_summaries_path}/${params.trait}/GO_summaries_${goFile.baseName.split('_')[2]}_${goFile.baseName.split('_')[3]}/"),   emit: gosummaries
    path(goFile),               emit: gofile

    script:
    def oraSummaryDir = "${params.GO_summaries_path}/${params.trait}/GO_summaries_${goFile.baseName.split('_')[2]}_${goFile.baseName.split('_')[3]}/"
    """
    Rscript ${moduleDir}/bin/ORA_cmd.R --sigModuleDir ${sigModuleDir} --backGroundGenesFile ${goFile} \
        --summaryRoot "${oraSummaryDir}" --reportRoot "GO_reports/"

    """
}
