function test()
%TESTHDF5 Benchmark test of HDF5 speed versus binary file in writing FLOAT values
%   Also use as a reference how to use my API
    N = 999999;  % amount of lines streamed
    d = 7;  % dimensionality of data streamed

    % Generating random data sample
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
        fwrite(fileID, ar(i,:), 'float');
    end
    tFwrite = toc;
    fclose(fileID);

    %% test hdf5
    filename = 'dump_test.h5';
    dsetname = 'lol';  % name of the dataset inside the file

    % For the sake of performance I created an additional level of buffer
    % that keeps a bunch of data in memory and dumps it only when the buffer is
    % full. Adjust bufLength for your own data.
    bufLength = 10000;
    % Dataset needs to be created with a certain length. This is a starting
    % value. It will be updating when the it starts to run out.
    fileLength = 100000;
    createHdf5(filename, dsetname, d, bufLength, fileLength);

    [fileID, datasetID] = openHdf5(filename, dsetname);
    tic;
    for i = 1:N
        appendHdf5(datasetID, ar(i, :))
    end
    tHdf5 = toc;
    closeHdf5(filename, fileID, datasetID);

    fprintf('Average time of fwrite is \t\t%f msec\n', tFwrite/N*1000);
    fprintf('Average time of hdf5 write is \t%f msec\n', tHdf5/N*1000);

    %% Check if actually wrote right data
    fileID = H5F.open(filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
    datasetID = H5D.open(fileID, dsetname);
    returned_data = H5D.read(datasetID,'H5ML_DEFAULT',...
                             'H5S_ALL','H5S_ALL','H5P_DEFAULT');
    % We need to cut excessive data, because we preallocated space
    counter_attr_id = H5A.open(datasetID, 'counter');
    counter = H5A.read(counter_attr_id);
    returned_data = returned_data(1:counter-1, :);
    if isequal(single(ar), returned_data)
        disp('Data written correctly')
    else
        disp('Warning! Data written INCORRECTLY')
    end
%     disp(ar);
%     disp(returned_data);
    H5D.close(datasetID);
    H5F.close(fileID)
end

% SAMPLE OUPUT: (and two data files) WITHOUT gzip
% Created file:
% HDF5 dump_test.h5
% Group '/'
%     Dataset 'lol'
%         Size:  100000x7
%         MaxSize:  Infx7
%         Datatype:   H5T_IEEE_F32LE (single)
%         ChunkSize:  10000x7
%         Filters:  none
%         FillValue:  0.000000
%         Attributes:
%             'dim':  7.000000
%             'bufLength':  10000.000000
%             'counter':  1.000000
%             'fileLength':  100000.000000
% Closed file:
% HDF5 dump_test.h5
% Group '/'
%     Dataset 'lol'
%         Size:  1100000x7
%         MaxSize:  Infx7
%         Datatype:   H5T_IEEE_F32LE (single)
%         ChunkSize:  10000x7
%         Filters:  none
%         FillValue:  0.000000
%         Attributes:
%             'dim':  7.000000
%             'bufLength':  10000.000000
%             'counter':  1000000.000000
%             'fileLength':  1100000.000000
% Average time of fwrite is       0.010892 msec
% Average time of hdf5 write is   0.017116 msec
% Data written correctly


% SAMPLE OUPUT: (and two data files) WITH gzip (.h5 slightly smaller 27 vs 24 MB)
% Created file:
% ---- SKIPPED -----
% Average time of fwrite is       0.010692 msec
% Average time of hdf5 write is   0.018618 msec
% Data written correctly
