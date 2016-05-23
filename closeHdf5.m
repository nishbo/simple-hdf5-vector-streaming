function closeHdf5( filename, fileID, datasetID)
%CLOSEHDF5 Summary of this function goes here
%   Detailed explanation goes here
    global hdf5Stride hdf5Count hdf5Block
    global hdf5Counter hdf5Counter2 hdf5Buffer hdf5FileLength
    space = H5D.get_space(datasetID);

    %% Write the leftover buffer
    start = [0 hdf5Counter - 1];
    H5S.select_hyperslab(space, 'H5S_SELECT_SET', start, hdf5Stride, hdf5Count, hdf5Block);
    memspaceID = H5S.create_simple(2, hdf5Block, []);
    H5D.write(datasetID, 'H5T_NATIVE_FLOAT', memspaceID, space,'H5P_DEFAULT', single(hdf5Buffer'));
    hdf5Counter = hdf5Counter + hdf5Counter2 - 1;

    %% Save possibly changed metadata
    counter_attr_id = H5A.open(datasetID, 'counter');
    H5A.write(counter_attr_id, 'H5ML_DEFAULT', hdf5Counter);
    H5A.close(counter_attr_id);
    fileLength_attr_id = H5A.open(datasetID, 'fileLength');
    H5A.write(fileLength_attr_id, 'H5ML_DEFAULT', hdf5FileLength);
    H5A.close(fileLength_attr_id);

    %% Actually close stuff
    H5D.close(datasetID);
    H5S.close(space);
    H5F.close(fileID);

    %% Disp final state of file
    disp('Closed file:')
    h5disp(filename)
end

