// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process M6ANET_INFERENCE {
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'rna_modification/m6anet_inference', publish_id:'') }

 //   conda     (params.enable_conda ? "bioconda::nanopolish==0.13.2" : null) // need to get xpore onto conda
    container "docker.io/yuukiiwa/m6anet:0.0.1"

    input:
    tuple path(dir), val(sample)
    
    output:
    path "*", emit: m6anet_outputs

    script:
    def input_dir = dir+'/m6anet'
    """
    m6anet-run_inference --input_dir $input_dir --out_dir $sample  --batch_size 512 --num_workers $params.guppy_cpu_threads --num_iterations 5 --device cpu
    """

}
