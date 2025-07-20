//
// Subworkflow with functionality specific to the nf-core/fishnetpipeline pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { RUN_PASCAL } from '../../modules/local/run_pascal'
include { POSTPROCESS_PASCAL_OUTPUT } from '../../modules/local/postprocess_pascal_output'
include { GO_ANALYSIS } from '../../modules/local/go_analysis'
include { MERGE_RESULTS } from '../../modules/local/merge_results'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOW TO INITIALISE PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MODULE_ENRICHMENT {

    take:
    go
    module
    go

    main:
    //
    // module: run pascal
    //
    RUN_PASCAL (
        gs | flatten,
        module | flatten,
        go | flatten
    )

    //
    // module: process pascal output files
    //
    POSTPROCESS_PASCAL_OUTPUT (
        RUN_PASCAL.out.pascaloutput | flatten,
        RUN_PASCAL.out.genescorefile | flatten,
        RUN_PASCAL.out.gofile | flatten
    )

    //
    // module: run GO analysis
    //
    GO_ANALYSIS (
        POSTPROCESS_PASCAL_OUTPUT.out.summaryslice | flatten,
        POSTPROCESS_PASCAL_OUTPUT.out.sigmodules | flatten,
        POSTPROCESS_PASCAL_OUTPUT.out.gofile | flatten
    )

    //
    // module: merge GO analysis results
    //
    MERGE_RESULTS (
        GO_ANALYSIS.out.mastersummaryslice | flatten,
        GO_ANALYSIS.out.gosummaries | flatten,
        GO_ANALYSIS.out.gofile | flatten
    )

}
