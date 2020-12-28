// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process MULTIQC {
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda     (params.enable_conda ? "bioconda::multiqc=1.9" : null)
    container "quay.io/biocontainers/multiqc:1.9--pyh9f0ad1d_0"

    input:
    path multiqc_config
    path multiqc_custom_config
    path ('pycoqc/*') from ch_pycoqc_multiqc.collect().ifEmpty([])
    path ('fastqc/*') from ch_fastqc_multiqc.collect().ifEmpty([])
    path ('samtools/*') from ch_sortbam_stats_multiqc.collect().ifEmpty([])
    path ('featurecounts/gene/*') from ch_featurecounts_gene_multiqc.collect().ifEmpty([])
    path ('featurecounts/transcript/*') from ch_featurecounts_transcript_multiqc.collect().ifEmpty([])
    path ('software_versions/*') from software_versions_yaml.collect()
    path workflow_summary
    
    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots

    script:
    def software      = getSoftwareName(task.process)
    def custom_config = params.multiqc_config ? "--config $multiqc_custom_config" : ''
    """
    multiqc -f $options.args $custom_config .
    """
}
