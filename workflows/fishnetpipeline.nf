/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FISHNET_PHASE1 } from '../subworkflows/local/fishnet_phase1'
include { FISHNET_PHASE2 } from '../subworkflows/local/fishnet_phase2'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FISHNETPIPELINE {

    main:
    // set up channels
    ch_versions = Channel.empty()

    //
    // subworkflow: phase 1 (module enrichment analysis)
    //
    FISHNET_PHASE1 (
        params.input,
        params.input_modules
    )
    ch_versions = ch_versions.mix(FISHNET_PHASE1.out.versions)

    //
    // subworkflow: phase 2
    //
    FISHNET_PHASE2 (
        params.input,
        params.input_modules,
        params.input_networks,
        FISHNET_PHASE1.out.master_summary_filtered_parsed,
        FISHNET_PHASE1.out.gosummaries_path
    )
    ch_versions = ch_versions.mix(FISHNET_PHASE2.out.versions)

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
