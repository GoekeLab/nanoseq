/*
 * Transcript Discovery and Quantification with StringTie2 and FeatureCounts
 */

def jaffal_options            = [:]

include { GET_JAFFAL_REF } from '../../modules/local/get_jaffal_ref'        addParams( options: [:]            )
include { UNTAR          } from '../../modules/nf-core/software/untar/main' addParams( options: [:]            )
include { JAFFAL         } from '../../modules/local/jaffal'                addParams( options: jaffal_options )

workflow RNA_FUSIONS_JAFFAL {
    take:
    ch_sample
    jaffal_ref_dir

    main:

    if (jaffal_ref_dir) {
        ch_jaffal_ref_dir = file(params.jaffal_ref_dir, checkIfExists: true)
    } else { 
        GET_JAFFAL_REF()
        UNTAR( GET_JAFFAL_REF.out.ch_jaffal_ref )
        ch_jaffal_ref_dir = UNTAR.out.untar
    }

    ch_sample
       .map { it -> [ it[0], it[6] ]}
       .set { ch_jaffal_input }

    /*
     * Align current signals to reference with Nanopolish
     */
     JAFFAL( ch_jaffal_input, ch_jaffal_ref_dir )

//    emit:
//    ch_nanopolish_outputs
//    ch_dataprep_dirs
//    nanopolish_version
}
