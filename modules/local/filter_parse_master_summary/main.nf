process FILTER_PARSE_MASTER_SUMMARY {

    label 'process_low'

    input:
    path master_summary_file

    output:
    path("master_summary_filtered.csv"),            emit: master_summary_filtered
    path("master_summary_filtered_parsed.csv"),     emit: master_summary_filtered_parsed
    path("versions.yml"),                           emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    ( head -n1 "${master_summary_file}"; grep 'True' "${master_summary_file}") > ./master_summary_filtered.csv
    cut -d ',' -f1-8 master_summary_filtered.csv > master_summary_filtered_parsed.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version)
    END_VERSIONS
    """
}
