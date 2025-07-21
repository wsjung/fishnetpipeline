//
// Subworkflow with functionality specific to the nf-core/fishnetpipeline pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { GENERATE_OR_STATISTICS_DEFAULT } from '../../../modules/local/generate_or_statistics_default'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOW TO INITIALISE PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FISHNET_PHASE2 {

    // inputs:
    // @input_traits: currently written for a single-trait input (input_traits),
    //                a path to the input summary statistics file
    // @input_modules_path: path to directory containing network modules
    //                      (can be any number of modules)
    take:
    input_traits
    input_modules
    master_summary_filtered_parsed
    gosummaries_path

    main:
    ch_trait_files = Channel.fromPath(input_traits)
    ch_input_modules = Channel.fromPath("${input_modules}/*.txt")

    // find each pair of trait and module files
    ch_trait_module_pairs = ch_trait_files
        .combine( ch_input_modules )

    // add trait name and module name
    ch_trait_module_pairs = ch_trait_module_pairs
        .map { Path traitFile, Path modFile ->
            tuple (traitFile, traitFile.baseName.replaceFirst(/^\d+-/, ''), modFile, modFile.baseName )
        }

    gosummaries_path.view()


    //
    // module: preprocess input data for pascal
    //
    GENERATE_OR_STATISTICS_DEFAULT (
        ch_trait_module_pairs,
        master_summary_filtered_parsed,
        gosummaries_path
    )
}
