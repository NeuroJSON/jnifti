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
%% @deftypefn  {Function File} {} niftiread (@var{filename})
%% @deftypefnx {Function File} {} niftiread (@var{headerfile}, @var{imagefile})
%% @deftypefnx {Function File} {} niftiread (@var{info})
%% Read image data from a NIfTI-1/2 and Analyze7.5 formatted image file
%%
%% Loading a NIfTI-1/2 file specified by @var{filename}, or a two-part NIfTI 
%% or Analyze7.5 files using @var{headerfile} and @var{imagefile}. The 
%% accepted file suffixes include .nii, .nii.gz, .hdr, .hdr.gz, .img, img.gz
%%
%% @seealso{niftiinfo, niftiwrite}
%% @end deftypefn

function img = niftiread (filename, varargin)

if(isempty(varargin) && isstruct(filename))
    nii=nii2jnii(filename.Filename);
else
    nii=nii2jnii(filename);
end

if(isfield(nii,'NIFTIData'))
    img=nii.NIFTIData;
else
    error('niftiread: can not load image data from specified file');
end

endfunction


%!demo
%! %% Reading a
%! urlwrite('https://nifti.nimh.nih.gov/nifti-1/data/minimal.nii.gz','minimal.nii.gz')
%! gunzip ('minimal.nii.gz');
%! img=niftiread('minimal.nii');

%!test
%! urlwrite('https://nifti.nimh.nih.gov/nifti-1/data/minimal.nii.gz','minimal.nii.gz')
%! gunzip ('minimal.nii.gz');
%! img=niftiread('minimal.nii');
%! assert (size(img),[64 64 10]);
