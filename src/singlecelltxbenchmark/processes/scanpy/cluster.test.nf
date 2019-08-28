//
// Test: passed 
// Command: 
//  nextflow src/processes/scanpy/cluster.test.nf --tenx_folder data/01.count/**/filtered_feature_bc_matrix --project_name tiny -resume
//
nextflow.preview.dsl=2

//////////////////////////////////////////////////////
//  Define the parameters for current testing proces
include '../utils/utils' params(iff: '10x_mtx', off: 'h5ad', project_name: params.project_name)

include './filter' params(
    cellFilterMinNGenes: 10,
    geneFilterMinNCells: 1,
    iff: '10x_mtx',
    off: 'h5ad'
)

include SC__SCANPY__NORMALIZATION from './transform' params(
    normalizationMethod: 'cpx',
    normalizationNumberReadsPerCellFactor: 10000,
    iff: '10x_mtx',
    off: 'h5ad'
)

include SC__SCANPY__DATA_TRANSFORMATION from './transform' params(
    dataTransformationMethod: 'log1p',
    iff: '10x_mtx',
    off: 'h5ad'
)

include './feature_selection' params(
    featureSelectionMethod: 'mean_disp_plot',
    featureSelectionMinMean: 0.0125,
    featureSelectionMaxMean: 3,
    featureSelectionMinDisp: 0.5,
    iff: '10x_mtx',
    off: 'h5ad'
)

include './adjust' params(
    adjustmentMethod: 'linear_regression',
    normalizationVariablesToRegressOut: ['n_counts'], // percent_mito
    iff: '10x_mtx',
    off: 'h5ad'
)

include './batch_effect_correct' params(
    batchEffectCorrectionMethod: 'mnn',
    nJobs: 2,
    project_name: params.project_name,
    iff: '10x_mtx',
    off: 'h5ad'
)

include SC__SCANPY__CLUSTERING from './cluster' params(
    clusteringMethod: 'Louvain',
    resolution: 0.8,
    iff: '10x_mtx',
    off: 'h5ad'
)

//////////////////////////////////////////////////////
//  Get the data
include getChannel as getTenXChannel from '../../channels/tenx.nf'

/*
 * Make the test workflow 
 * Run the simple workflow for each 10xGenomics CellRanger output folders specified.
 * Steps considered: dimensionality reduction
 */ 
workflow test_cluster {
    get:
        data
    main:
        SC__FILE_CONVERTER( data )
        SC__SCANPY__CLUSTERING( SC__FILE_CONVERTER.out )
    emit:
        SC__SCANPY__CLUSTERING.out
}

// Uncomment to test
// test_cluster( getTenXChannel( params.tenx_folder ) )

/*
 * Make the test workflow 
 * Run the workflow for each 10xGenomics CellRanger output folders specified 
 * until accounting for covariates. Then combines the files, do scaling, dimensionality reduction and batch effect correction
 */ 
workflow test__from_raw__aggr_batch {
    get:
        data
    main:
        SC__FILE_CONVERTER( data )
        SC__SCANPY__GENE_FILTER( SC__FILE_CONVERTER.out )
        SC__SCANPY__CELL_FILTER( SC__SCANPY__GENE_FILTER.out )
        SC__SCANPY__FILTER_QC_REPORT( SC__SCANPY__CELL_FILTER.out )
        SC__SCANPY__NORMALIZATION( SC__SCANPY__CELL_FILTER.out )
        SC__SCANPY__DATA_TRANSFORMATION( SC__SCANPY__NORMALIZATION.out )
        SC__SCANPY__FEATURE_SELECTION( SC__SCANPY__DATA_TRANSFORMATION.out )
        SC__SCANPY__ADJUSTMENT( SC__SCANPY__FEATURE_SELECTION.out )
        SC__SCANPY__BATCH_EFFECT_CORRECTION( SC__SCANPY__ADJUSTMENT.out.collect() )
        SC__SCANPY__CLUSTERING( SC__SCANPY__BATCH_EFFECT_CORRECTION.out )
    emit:
        SC__SCANPY__CLUSTERING.out
}

// Uncomment to test
workflow {
    main:
        test__from_raw__aggr_batch( getTenXChannel( params.tenx_folder ) )   
}