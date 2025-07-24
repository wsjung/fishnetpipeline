//
// Subworkflow with functionality specific to the nf-core/fishnetpipeline pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PREPROCESS_FOR_PASCAL } from '../../../modules/local/preprocess_for_pascal'
include { RUN_PASCAL } from '../../../modules/local/run_pascal'
include { POSTPROCESS_PASCAL_OUTPUT } from '../../../modules/local/postprocess_pascal_output'
include { GO_ANALYSIS } from '../../../modules/local/go_analysis'
include { MERGE_RESULTS } from '../../../modules/local/merge_results'
include { COMPILE_PHASE1_RESULTS } from '../../../modules/local/compile_phase1_results'
include { FILTER_PARSE_MASTER_SUMMARY } from '../../../modules/local/filter_parse_master_summary'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOW TO INITIALISE PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FISHNET_PHASE1 {

    // inputs:
    // @input_traits: currently written for a single-trait input (input_traits),
    //                a path to the input summary statistics file
    // @input_modules_path: path to directory containing network modules
    //                      (can be any number of modules)
    take:
    input_traits
    input_modules_path

    main:
    // set up empty channels
    ch_versions = Channel.empty()

    //
    // module: preprocess input data for pascal
    //
    PREPROCESS_FOR_PASCAL (
        input_traits,
        input_modules_path
    )
    ch_versions = ch_versions.mix(PREPROCESS_FOR_PASCAL.out.versions)

    //
    // module: run pascal
    //
    RUN_PASCAL (
        PREPROCESS_FOR_PASCAL.out.gs | flatten,
        PREPROCESS_FOR_PASCAL.out.module | flatten,
        PREPROCESS_FOR_PASCAL.out.go | flatten
    )
    ch_versions = ch_versions.mix(RUN_PASCAL.out.versions)

    //
    // module: process pascal output files
    //
    POSTPROCESS_PASCAL_OUTPUT (
        RUN_PASCAL.out.pascaloutput | flatten,
        RUN_PASCAL.out.genescorefile | flatten,
        RUN_PASCAL.out.gofile | flatten
    )
    ch_versions = ch_versions.mix(POSTPROCESS_PASCAL_OUTPUT.out.versions)

    //
    // module: run GO analysis
    //
    GO_ANALYSIS (
        POSTPROCESS_PASCAL_OUTPUT.out.summaryslice | flatten,
        POSTPROCESS_PASCAL_OUTPUT.out.sigmodules | flatten,
        POSTPROCESS_PASCAL_OUTPUT.out.gofile | flatten
    )
    ch_versions = ch_versions.mix(GO_ANALYSIS.out.versions)

    //
    // module: merge GO analysis results
    //
    MERGE_RESULTS (
        GO_ANALYSIS.out.mastersummaryslice | flatten,
        GO_ANALYSIS.out.gosummaries | flatten,
        GO_ANALYSIS.out.gofile | flatten
    )
    ch_versions = ch_versions.mix(MERGE_RESULTS.out.versions)

    //
    // module: compile phase 1 results to a master summary file
    //
    COMPILE_PHASE1_RESULTS (
        MERGE_RESULTS.out.summaries_path
    )
    ch_versions = ch_versions.mix(COMPILE_PHASE1_RESULTS.out.versions)

    //
    // module: filter and parse master summary file
    //
    FILTER_PARSE_MASTER_SUMMARY (
        COMPILE_PHASE1_RESULTS.out.master_summary_file
    )
    ch_versions = ch_versions.mix(FILTER_PARSE_MASTER_SUMMARY.out.versions)

    emit:
    master_summary_filtered_parsed = FILTER_PARSE_MASTER_SUMMARY.out.master_summary_filtered_parsed
    gosummaries_path = GO_ANALYSIS.out.gosummaries | flatten
    versions = ch_versions

}
