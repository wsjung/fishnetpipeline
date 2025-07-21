//
// Subworkflow with functionality specific to the nf-core/fishnetpipeline pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { GENERATE_OR_STATISTICS_DEFAULT } from '../../../modules/local/generate_or_statistics_default'
include { IDENTIFY_MEA_PASSING_GENES } from '../../../modules/local/identify_mea_passing_genes'

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
    input_networks
    master_summary_filtered_parsed
    gosummaries_path

    main:
    // set up channels
    ch_trait_files = Channel.fromPath(input_traits)
    ch_input_modules = Channel.fromPath("${input_modules}/*.txt")
    ch_networks = Channel.value(input_networks)

    // find each pair of trait and module files
    ch_trait_module = ch_trait_files
        .combine( ch_input_modules )

    // add trait name and module name
    ch_trait_module = ch_trait_module
        .map { Path traitFile, Path modFile ->
            tuple (traitFile, traitFile.baseName.replaceFirst(/^\d+-/, ''), modFile, modFile.baseName )
        }

    // add network files
    ch_trait_module_network = ch_trait_module
        .combine( ch_networks )
        .map { traitFile, traitName, modFile, modName, networkPath ->
            def netFile = file("${networkPath}/${modName}.txt")
            tuple( traitFile, traitName, modName, modFile, netFile )
        }


    //
    // module: preprocess input data for pascal
    //
    GENERATE_OR_STATISTICS_DEFAULT (
        ch_trait_module_network,
        master_summary_filtered_parsed,
        gosummaries_path
    )

    //
    // module: identify MEA passing genes (FISHNET genes)
    //
    IDENTIFY_MEA_PASSING_GENES (
        GENERATE_OR_STATISTICS_DEFAULT.out.or_fishnet_genes,
        GENERATE_OR_STATISTICS_DEFAULT.out.trait_file,
        GENERATE_OR_STATISTICS_DEFAULT.out.trait,
        GENERATE_OR_STATISTICS_DEFAULT.out.module_file,
        GENERATE_OR_STATISTICS_DEFAULT.out.module_name,
        GENERATE_OR_STATISTICS_DEFAULT.out.network_file,
        GENERATE_OR_STATISTICS_DEFAULT.out.master_summary_filtered_parsed,
    )
}
