/*
 * Convert BAM to BigBed
 */

params.bigbed_options   = [:]

include { BEDTOOLS_BAMBED     } from '../process/bedtools_bamtobed'        addParams( options: params.bigbed_options )
include { UCSC_BED12TOBIGBED  } from '../process/ucsc_bed12tobigbed'       addParams( options: params.bigbed_options )

workflow BEDTOOLS_UCSC_BIGBED {
    take:
    ch_sortbam
    
    main:
    /*
     * Convert BAM to BED12
     */
    BEDTOOLS_BAMBED ( ch_sortbam )
    ch_bed12 = BEDTOOLS_BAMBED.out.bed12

    /*
     * Convert BED12 to BigBED
     */
    UCSC_BED12TOBIGBED ( ch_bed12 )
    ch_bigbed = UCSC_BED12TOBIGBED.out.bigbed

    emit:
    ch_bigbed
}