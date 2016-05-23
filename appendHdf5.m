function appendHdf5( datasetID, dat )
%APPENDHDF5 Summary of this function goes here
%   Detailed explanation goes here
    global hdf5Counter hdf5Stride hdf5Count hdf5Block hdf5Buffer hdf5Counter2 hdf5FileLength
    space = H5D.get_space(datasetID);

    % first save to virtual buffer
    hdf5Buffer(:, hdf5Counter2) = dat;
    hdf5Counter2 = hdf5Counter2 + 1;

    % Save to file
    if hdf5Counter2 > hdf5Block(2)
        % c@ http://www.hdfgroup.org/HDF5/doc1.6/RM_H5S.html#Dataspace-SelectHyperslab
        start = [0 hdf5Counter - 1];  % count from 0
        % disp(hdf5Counter - 1)
        H5S.select_hyperslab(space, 'H5S_SELECT_SET', start, hdf5Stride, hdf5Count, hdf5Block);

        % Write Data to selected dimensions
        memspaceID = H5S.create_simple(2, hdf5Block, []);
        H5D.write(datasetID, 'H5T_NATIVE_DOUBLE', memspaceID, space,'H5P_DEFAULT', hdf5Buffer');

        hdf5Counter = hdf5Counter + hdf5Counter2 - 1;
        hdf5Counter2 = 1;
        hdf5Buffer = zeros(hdf5Block);

        % Check if more space is needed in the file
        if hdf5Counter + hdf5Block(2) >= hdf5FileLength
%             disp('allocating more space')
            hdf5FileLength = hdf5FileLength + hdf5Block(2) * 100;
            % disp([hdf5Block(1) hdf5FileLength])
            H5D.set_extent(datasetID, [hdf5Block(1) hdf5FileLength]);
            % H5D.read(datasetID)
        end
    end
    H5S.close(space);
end

