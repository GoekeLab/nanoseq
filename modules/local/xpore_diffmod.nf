// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process XPORE_DIFFMOD {
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'rna_modification', publish_id:'') }

 //   conda     (params.enable_conda ? "bioconda::nanopolish==0.13.2" : null) // need to get xpore onto conda
    container "docker.io/yuukiiwa/xpore:w_m6anet"

    input:
    val dataprep_dirs
    
    output:
    path "diffmod*", emit: diffmod_outputs
    path "*_version.txt" , emit: version

    script:
    diffmod_config = "--config $workflow.workDir/*/*/diffmod_config.yml"
    """
    create_yml.py diffmod_config.yml $dataprep_dirs
    xpore-diffmod $diffmod_config --n_processes $params.guppy_cpu_threads
    python3 -c 'import xpore; print(xpore.__version__)' > xpore_version.txt
    """

}
