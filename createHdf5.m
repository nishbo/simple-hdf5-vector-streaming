function createHdf5(filename, dsetname, dim, bufLength, fileLength)
%CREATEHDF5 creates a database file for appending
%   Detailed explanation goes here
    fileID = H5F.create(filename, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');

    % Create dataspace with unlimited dimensions
    dims = [dim, fileLength];  % Current allocated space in the database
    maxdims = {dim, 'H5S_UNLIMITED'};  % maximum space after extending
    space = H5S.create_simple(2, dims, maxdims);

    % Create the dataset creation property list
    dcpl = H5P.create('H5P_DATASET_CREATE');
%     H5P.set_deflate(dcpl, 9);  % Add the gzip compression filter
    % Set the chunk (input data) size
    chunk = [dim, bufLength];
    H5P.set_chunk(dcpl, chunk);

    % Create the compressed unlimited dataset
    datasetID = H5D.create(fileID, dsetname, 'H5T_NATIVE_DOUBLE', space, dcpl);

    % Save some metadata about the dataset
    dim_attr_id = H5A.create(datasetID, 'dim', 'H5T_NATIVE_DOUBLE', ...
        H5S.create('H5S_SCALAR'), H5P.create('H5P_ATTRIBUTE_CREATE'));
    H5A.write(dim_attr_id, 'H5ML_DEFAULT', dim);
    H5A.close(dim_attr_id);
    buflength_attr_id = H5A.create(datasetID, 'bufLength', 'H5T_NATIVE_DOUBLE', ...
        H5S.create('H5S_SCALAR'), H5P.create('H5P_ATTRIBUTE_CREATE'));
    H5A.write(buflength_attr_id, 'H5ML_DEFAULT', bufLength);
    H5A.close(buflength_attr_id);
    counter_attr_id = H5A.create(datasetID, 'counter', 'H5T_NATIVE_DOUBLE', ...
        H5S.create('H5S_SCALAR'), H5P.create('H5P_ATTRIBUTE_CREATE'));
    H5A.write(counter_attr_id, 'H5ML_DEFAULT', 1);
    H5A.close(counter_attr_id);
    fileLength_attr_id = H5A.create(datasetID, 'fileLength', 'H5T_NATIVE_DOUBLE', ...
        H5S.create('H5S_SCALAR'), H5P.create('H5P_ATTRIBUTE_CREATE'));
    H5A.write(fileLength_attr_id, 'H5ML_DEFAULT', fileLength);
    H5A.close(fileLength_attr_id);

    % Close everything
    H5P.close(dcpl);
    H5S.close(space);
    H5F.close(fileID);

    % Output info about created file
    disp('Created file:')
    h5disp(filename)
end

