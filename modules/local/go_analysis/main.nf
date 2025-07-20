process GO_ANALYSIS {

    container 'jungwooseok/r-webgestaltr:1.0' // TODO: add to biocontainers
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
