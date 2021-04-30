// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process M6ANET_INFERENCE {
    tag "$meta.id"
    echo true
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'rna_modification/m6anet_inference', publish_id:meta.id) }

 //   conda     (params.enable_conda ? "bioconda::nanopolish==0.13.2" : null) // need to get xpore onto conda
    container "docker.io/yuukiiwa/m6anet:0.0.1"

    input:
    tuple val(meta), path(dir)
    
    output:
    path "*", emit: m6anet_outputs
    path "*_version.txt", emit: version

    script:
    def input_dir = dir+'/m6anet'
    def out_dir = meta.id+"_results"
    """
    m6anet-run_inference --input_dir $input_dir --out_dir $out_dir  --batch_size 512 --num_workers $params.guppy_cpu_threads --num_iterations 5 --device cpu
    echo '0.0.1' > m6anet_version.txt
    """
}
