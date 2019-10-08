nextflow.preview.dsl=2

include getBaseName from '../../utils/processes/files.nf'

process SC__SCANPY__NORMALIZATION {

  container params.sc.scanpy.container
  publishDir "${params.outdir}/data", mode: 'symlink'

  input:
    file(f)
  output:
    file "${getBaseName(f)}.SC__SCANPY__NORMALIZATION.${params.off}"
  script:
    """
    ${workflow.projectDir}/src/scanpy/bin/transform/sc_normalization.py \
        ${(params.containsKey('normalizationMethod')) ? '--method ' + params.normalizationMethod : ''} \
        ${(params.containsKey('countsPerCellAfter')) ? '--counts-per-cell-after ' + params.countsPerCellAfter : ''} \
        $f \
        "${getBaseName(f)}.SC__SCANPY__NORMALIZATION.${params.off}"
    """
}

process SC__SCANPY__DATA_TRANSFORMATION {

  container params.sc.scanpy.container
  publishDir "${params.outdir}/data", mode: 'symlink'

  input:
    file(f)
  output:
    file "${getBaseName(f)}.SC__SCANPY__DATA_TRANSFORMATION.${params.off}"
  script:
    """
    ${workflow.projectDir}/src/scanpy/bin/transform/sc_data_transformation.py \
        ${(params.containsKey('dataTransformationMethod')) ? '--method ' + params.dataTransformationMethod : ''} \
        $f \
        "${getBaseName(f)}.SC__SCANPY__DATA_TRANSFORMATION.${params.off}"
    """
}

process SC__SCANPY__FEATURE_SCALING {

  container params.sc.scanpy.container
  publishDir "${params.outdir}/data", mode: 'symlink'

  input:
    file(f)
  output:
    file "${getBaseName(f)}.SC__SCANPY__FEATURE_SCALING.${params.off}"
  script:
    """
    ${workflow.projectDir}/src/scanpy/bin/transform/sc_feature_scaling.py \
        ${(params.containsKey('featureScalingMthod')) ? '--method ' + params.featureScalingMthod : ''} \
        ${(params.containsKey('featureScalingMaxSD')) ? '--max-sd ' + params.featureScalingMaxSD : ''} \
       $f \
       "${getBaseName(f)}.SC__SCANPY__FEATURE_SCALING.${params.off}"
    """
}