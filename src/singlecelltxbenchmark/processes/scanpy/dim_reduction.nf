nextflow.preview.dsl=2

include getBaseName from '../../utils/files.nf'

process SC__SCANPY__DIM_REDUCTION {
  input:
    file(f)
  output:
    file "${getBaseName(f)}.SC__SCANPY__DIM_REDUCTION.${params.off}"
  script:
    """
    python ../../../src/singlecelltxbenchmark/scripts/scanpy/dim_reduction/sc_dim_reduction.py \
         ${(params.containsKey('dimReductionMethod')) ? '--method ' + params.method : ''} \
         ${(params.containsKey('svdSolver')) ? '--svd-solver ' + params.svdSolver : ''} \
         ${(params.containsKey('nNeighbors')) ? '--n-neighbors ' + params.nNeighbors : ''} \
         ${(params.containsKey('nComps')) ? '--n-comps ' + params.nComps : ''} \
         ${(params.containsKey('nPcs')) ? '--n-pcs ' + params.nPcs : ''} \
         ${(params.containsKey('nJobs')) ? '--n-jobs ' + params.nJobs : ''} \
         $f \
         "${getBaseName(f)}.SC__SCANPY__DIM_REDUCTION.${params.off}"
    """
}