function config_io

%   Set of functions, that provide fast I/O prt use with Matlab
%   Source: http://apps.usd.edu/coglab/psyc770/IO64.html

global cogent;

%create IO64 interface object
cogent.io.ioObj = io64();

%install the inpoutx64.dll driver
%status = 0 if installation successful
cogent.io.status = io64(cogent.io.ioObj);
if(cogent.io.status ~= 0)
    disp('inp/outp installation failed!')
end