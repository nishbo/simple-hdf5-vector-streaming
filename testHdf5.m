function testHdf5(  )
%TESTHDF5 Summary of this function goes here
%   Detailed explanation goes here
    N = 999999;
    d = 7;
    frmt = sprintf('double');

    ar = zeros(N, d);
    for i=1:d
        for j=1:N
            ar(j, i) = rand();
        end
    end

    %% test fwrite
    fileID = fopen('dump_test.txt', 'w');
    tic;
    for i=1:N
        fwrite(fileID, ar(i,:), frmt);
    end
    tFwrite = toc;
    fclose(fileID);

    %% test hdf5
    filename = 'dump_test.h5';
    dsetname = 'lol';

    bufLength = 1000;
    fileLength = 100000;
    createHdf5(filename, dsetname, d, bufLength, fileLength);

    [ fileID, datasetID ] = openHdf5(filename, dsetname);
    tic;
    for i = 1:N
        appendHdf5(datasetID, ar(i,:))
    end
    tHdf5 = toc;
    closeHdf5(filename, fileID, datasetID);

    fprintf('Average time of fwrite is \t\t%f msec\n', tFwrite/N*1000);
    fprintf('Average time of hdf5 write is \t%f msec\n', tHdf5/N*1000);

    %% Check if actually wrote right
    fileID = H5F.open(filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
    datasetID = H5D.open(fileID, dsetname);
    returned_data = H5D.read(datasetID,'H5ML_DEFAULT',...
                             'H5S_ALL','H5S_ALL','H5P_DEFAULT');
    counter_attr_id = H5A.open(datasetID, 'counter');
    counter = H5A.read(counter_attr_id);
    returned_data = returned_data(1:counter-1, :);
    if isequal(ar, returned_data)
        disp('Data written correctly')
    else
        disp('Warning! Data written INCORRECTLY')
    end
%     disp(ar);
%     disp(returned_data);
    H5D.close(datasetID);
    H5F.close(fileID)
end

