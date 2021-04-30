/*
 * Transcript Discovery and Quantification with StringTie2 and FeatureCounts
 */

def nanopolish_options            = [:]
def xpore_m6anet_dataprep_options = [:]
def xpore_diffmod_options         = [:]
def m6anet_inference_options      = [:]

include { NANOPOLISH            } from '../../modules/local/nanopolish'            addParams( options: nanopolish_options            )
include { XPORE_M6ANET_DATAPREP } from '../../modules/local/xpore_m6anet_dataprep' addParams( options: xpore_m6anet_dataprep_options )
include { XPORE_DIFFMOD         } from '../../modules/local/xpore_diffmod'         addParams( options: xpore_diffmod_options         )
include { M6ANET_INFERENCE      } from '../../modules/local/m6anet_inference'      addParams( options: m6anet_inference_options      )

workflow RNA_MODIFICATION_XPORE_M6ANET {
    take:
    ch_sample
    ch_nanopolish_sortbam

    main:

    ch_sample
         .join(ch_nanopolish_sortbam)
         .map { it -> [ it[0], it[2], it[3], it[7], it[6], it[8], it[9] ] }
         .set { ch_nanopolish_input }

    /*
     * Align current signals to reference with Nanopolish
     */
    NANOPOLISH { ch_nanopolish_input }
    ch_nanopolish_outputs = NANOPOLISH.out.nanopolish_outputs
    nanopolish_version    = NANOPOLISH.out.version
    
    if (!params.skip_xpore || !params.skip_m6anet) {

        /*
         * Dataprep for xpore and/or m6anet
         */
        XPORE_M6ANET_DATAPREP( ch_nanopolish_outputs )
        ch_dataprep_dirs = XPORE_M6ANET_DATAPREP.out.dataprep_outputs
        xpore_version = ''
        if (!params.skip_xpore) {
            ch_dataprep_dirs
                .map{ it -> it[1]+','+it[0].id }
                .set{ ch_xpore_diffmod_inputs }
            /*
             * Differential modification expression with xpore
             */
            XPORE_DIFFMOD{ ch_xpore_diffmod_inputs.collect() }
            xpore_version    = XPORE_DIFFMOD.out.version
        }
        m6anet_version = ''
        if (!params.skip_m6anet) {
            /*
             * Detect m6A sites with m6anet
             */
            M6ANET_INFERENCE{ ch_dataprep_dirs }
            m6anet_version   = M6ANET_INFERENCE.out.version
        }
    }

    emit:
    ch_nanopolish_outputs
    ch_dataprep_dirs
    nanopolish_version
//    xpore_version
    m6anet_version
}
