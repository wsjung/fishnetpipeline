process FILTER_PARSE_MASTER_SUMMARY {

    label 'process_low'
    publishDir "${params.outdir}/${params.pipeline}/", mode: 'copy'

    input:
    path master_summary_file

    output:
    path "master_summary_filtered.csv", emit: master_summary_filtered
    path "master_summary_filtered_parsed.csv", emit: master_summary_filtered_parsed

    script:
    """
    ( head -n1 "${master_summary_file}"; grep 'True' "${master_summary_file}") > ./master_summary_filtered.csv
    cut -d ',' -f1-8 master_summary_filtered.csv > master_summary_filtered_parsed.csv
    """
}
