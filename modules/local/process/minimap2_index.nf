// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process MINIMAP2_INDEX {
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda     (params.enable_conda ? "bioconda::minimap2=2.17" : null)
    container "quay.io/biocontainers/minimap2:2.17--hed695b0_3"

    input:
    tuple path(fasta), path(sizes), val(gtf), val(bed), val(is_transcripts), val(annotation_str)
    
    output:
    tuple path(fasta), path(sizes), val(gtf), val(bed), val(is_transcripts), path("*.mmi"), val(annotation_str), emit: index

    script:
    def preset    = (params.protocol == 'DNA' || is_transcripts) ? "-ax map-ont" : "-ax splice"
    def kmer      = (params.protocol == 'directRNA') ? "-k14" : ""
    def stranded  = (params.stranded || params.protocol == 'directRNA') ? "-uf" : ""
    // TODO pipeline: Should be staging bed file properly as an input
    def junctions = (params.protocol != 'DNA' && bed) ? "--junc-bed ${file(bed)}" : ""
    """
    minimap2 \\
        $preset \\
        $kmer \\
        $stranded \\
        $junctions \\
        -t $task.cpus \\
        -d ${fasta}.mmi \\
        $fasta
    ps
    """
}