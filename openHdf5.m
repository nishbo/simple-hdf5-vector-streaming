function [ fileID, datasetID ] = openHdf5(filename, dsetname)
%OPENHDF5 Summary of this function goes here
%   Detailed explanation goes here

    % Open Existing HDF5 File in 'H5F_ACC_RDWR' read-write mode
    fileID = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    % Open Existing Dataset
    datasetID = H5D.open(fileID, dsetname);

    % Extract some metadata
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

    % Setting global parameters for appending data. They will stay the same
    % for this dimensionality of dataset
    global hdf5Stride hdf5Count hdf5Block hdf5Counter hdf5Buffer hdf5Counter2 hdf5FileLength
    hdf5Stride = [1 1];
    hdf5Count = [1 1];
    hdf5Block = [dim bufLength];
    hdf5Counter = counter;
    hdf5Counter2 = 1;
    hdf5Buffer = zeros(dim, bufLength);
    hdf5FileLength = fileLength;

end

