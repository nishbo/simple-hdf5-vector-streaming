function [ fileID, datasetID ] = openHdf5(filename, dsetname)
%OPENHDF5 Opens a file with dataset and prepares for use
    %% Open Existing HDF5 File in 'H5F_ACC_RDWR' read-write mode
    fileID = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    % Open Existing Dataset
    datasetID = H5D.open(fileID, dsetname);

    %% Extract some metadata
    dim_attr_id = H5A.open(datasetID, 'dim');
    dim = H5A.read(dim_attr_id);
    H5A.close(dim_attr_id);

    counter_attr_id = H5A.open(datasetID, 'counter');
    counter = H5A.read(counter_attr_id);
    H5A.close(counter_attr_id);

    bufLength_attr_id = H5A.open(datasetID, 'bufLength');
    bufLength = H5A.read(bufLength_attr_id);
    H5A.close(bufLength_attr_id);

    fileLength_attr_id = H5A.open(datasetID, 'fileLength');
    fileLength = H5A.read(fileLength_attr_id);
    H5A.close(fileLength_attr_id);

    %% Setting global parameters for appending data.
    % hdf5Stride hdf5Count hdf5Block: stay the same and are needed for concervation
    %   of memory and processing power. Needed for HDF5 functions.
    global hdf5Stride hdf5Count hdf5Block
    hdf5Stride = [1 1];
    hdf5Count = [1 1];
    hdf5Block = [dim bufLength];
    % hdf5Counter hdf5Buffer hdf5Counter2 hdf5FileLength: are storing current
    %   metadata and processing.
    %       hdf5Counter - actual position in file (starts from 0)
    %       hdf5Counter2 - position inside buffer
    global hdf5Counter hdf5Buffer hdf5Counter2 hdf5FileLength
    hdf5Counter = counter;
    hdf5Counter2 = 1;
    hdf5Buffer = zeros(dim, bufLength);
    hdf5FileLength = fileLength;
end
