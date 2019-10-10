nextflow.preview.dsl=2

def extractSample(path) {
    // Allow to detect data generated by CellRanger prior and post to version 3.
    (full, parentDir, id) = (path =~ /(.+)\/(.+)\/outs/)[0]
    return id
}

workflow getChannel {
    get:
        glob
    main:
        // Check whether multiple globs are provided
        if(glob.contains(',')) {
            glob = Arrays.asList(glob.split(',')); 
        }
        channel = Channel
            .fromPath(glob, type: 'dir', checkIfExists: true)
            .map {
                path -> tuple(extractSample( "${path}" ), file("${path}"))
            }
    emit:
        channel
}
