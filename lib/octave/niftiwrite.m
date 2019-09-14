%% Copyright (C) 2019 Qianqian Fang <q.fang@neu.edu>
%%
%% This program is free software; you can redistribute it and/or modify it under
%% the terms of the GNU General Public License as published by the Free Software
%% Foundation; either version 3 of the License, or (at your option) any later
%% version.
%%
%% This program is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public License along with
%% this program; if not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn  {Function File} {} niftiwrite (@var{img}, @var{filename})
%% @deftypefnx {Function File} {} niftiwrite (@var{img}, @var{filename}, @var{info})
%% @deftypefnx {Function File} {} niftiwrite (@var{img}, @var{filename}, @var{info},...)
%% Write image data and metadata to a NIfTI-1/2 and Analyze7.5 formatted image file
%%
%% Writing image data @var{img} and metadata @var{info} to a NIfTI-1 
%% file or a two-part NIfTI or Analyze7.5 files specified by @var{filename}. 
%% The accepted file suffixes include .nii and .nii.gz.
%%
%% @seealso{niftiinfo, niftiread}
%% @end deftypefn

function niftiwrite (img, filename, varargin)

if(~isempty(varargin))
    if(isstruct(varargin{1}) && isfield(varargin{1},'raw'))
        header=varargin{1}.raw;
    elseif(ischar(varargin{1}))
        header=nifticreate(img,varargin{1});
    end
else
    header=nifticreate(img);
end

names=fieldnames(header);
buf=[];
for i=1:length(names)
    buf=[buf,typecast(header.(names{i}),'uint8')];
end

if(length(buf)~=352 && length(buf)~=544)
    error('incorrect nifti-1/2 header %d',length(buf));
end

buf=[buf,typecast(img(:)','uint8')];

if(regexp(filename,'\.[Gg][Zz]$'))
    buf=gzipencode(buf);
end

fid=fopen(filename,'wb');
if(fid==0)
    error('can not write to the specified file');
end
fwrite(fid,buf);
fclose(fid);

endfunction

%!demo
%! %% Reading a
%! urlwrite('https://nifti.nimh.nih.gov/nifti-1/data/minimal.nii.gz','minimal.nii.gz')
%! gunzip ('minimal.nii.gz');
%! header=niftiinfo('minimal.nii');

%!test
%! urlwrite('https://nifti.nimh.nih.gov/nifti-1/data/minimal.nii.gz','minimal.nii.gz')
%! gunzip ('minimal.nii.gz');
%! header=niftiinfo('minimal.nii');
%! assert (header.ImageSize,[64 64 10]);
