// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process JAFFAL {
    tag "$meta.id"
    echo true
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

//    conda     (params.enable_conda ? "bioconda::nanolyse=1.2.0" : null)   //need conda container
    container "docker.io/yuukiiwa/jaffa:2.0"

    input:
    tuple val(meta), path(fastq)
    path jaffal_ref_dir
    
    output:
    tuple val(meta), path("*.fasta") ,emit: jaffal_fastq
    path "*.csv"                     ,emit: jaffal_results
    path "*_version.txt"             ,emit: version

    script:
    """
    bpipe run -p refBase=$jaffal_ref_dir $jaffal_ref_dir/JAFFAL.groovy $fastq
    echo '2.0' > jaffal_version.txt
    """
}
