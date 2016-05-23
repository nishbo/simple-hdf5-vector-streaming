function appendHdf5( datasetID, dat )
%APPENDHDF5 Appends dat to the open dataset
%   Uses a buffer level and allocates more space if running out of file
    %% Save to virtual buffer
    global hdf5Block hdf5Buffer hdf5Counter2

    hdf5Buffer(:, hdf5Counter2) = dat;
    hdf5Counter2 = hdf5Counter2 + 1;

    %% Save to file
    if hdf5Counter2 > hdf5Block(2)
        global hdf5Counter hdf5Stride hdf5Count hdf5FileLength
        space = H5D.get_space(datasetID);

        start = [0 hdf5Counter - 1];  % count from 0
        % For more info see:
        % http://www.hdfgroup.org/HDF5/doc1.6/RM_H5S.html#Dataspace-SelectHyperslab
        H5S.select_hyperslab(space, 'H5S_SELECT_SET', start, hdf5Stride, hdf5Count, hdf5Block);

        % Write Data to selected dimensions
        memspaceID = H5S.create_simple(2, hdf5Block, []);
        H5D.write(datasetID, 'H5T_NATIVE_FLOAT', memspaceID, space,'H5P_DEFAULT', single(hdf5Buffer'));
        H5S.close(space);

        % Update all counters and reset the buffer
        hdf5Counter = hdf5Counter + hdf5Counter2 - 1;
        hdf5Counter2 = 1;
        hdf5Buffer = zeros(hdf5Block);

        % Check if more space is needed in the file
        if hdf5Counter + hdf5Block(2) >= hdf5FileLength
            hdf5FileLength = hdf5FileLength + hdf5Block(2) * 100;
            % Extend dimensions of the file
            H5D.set_extent(datasetID, [hdf5Block(1) hdf5FileLength]);
        end
    end
end

