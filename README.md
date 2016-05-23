# simple-hdf5-vector-streaming
Creates a simple HDF5 database and streams data into it.

Package contains a few well-documented functions that provide somewhat fast
high-level access to low-level HDF5 library from Matlab. Many thanks to
discussion at
https://www.mathworks.com/matlabcentral/newsreader/view_thread/284377

It is very minimalistic and very simple. Originally it was intended for actual
use in our lab during data acquisition, but also can be used to understand and
learn beginning of HDF5 and MATLAB.

Someone might want to replace a bunch of global variables that I used with
something smarter, but in my case they might be useful, better for workflow
(they should be touched very carefully outside of functions) and easier for
understanding. For example, hdf5Counter points at the first empty line in the
file.

function test()
    Provides a benchmark comparison of HDF5 performance and
    also describes general workflow of how to use the other functions. Read it
    first to understand.

function createHdf5(filename, dsetname, dim, bufLength, fileLength)
    Creates a file with single dataset and a bunch of metadata attributes.
    File and dataset are closed after creation.

function [ fileID, datasetID ] = openHdf5(filename, dsetname)
    Opens and existing database, sets up global counters and buffers.

function appendHdf5( datasetID, dat )
    Appends dat to the dataset. Uses a buffer to speed up things.

function closeHdf5( filename, fileID, datasetID)
    Saves remaining stuff in the buffer and closes the dataset and file.
