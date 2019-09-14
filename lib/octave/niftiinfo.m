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
%% @deftypefn  {Function File} {} niftiinfo (@var{filename})
%% Read the metadata from a NIfTI-1/2 and Analyze7.5 formatted image file
%%
%% Parsing the metadata in a NIfTI-1/2 file or a two-part NIfTI 
%% or Analyze7.5 header file specified by @var{filename}. The 
%% accepted file suffixes include .nii, .nii.gz, .hdr, and .hdr.gz.
%%
%% @seealso{niftiread, niftiwrite}
%% @end deftypefn

function nii = niftiinfo (filename, varargin)

if(nargin<1)
    error('must provide the file name');
end

try
    header=nii2jnii(filename,'niiheader');

    fileinfo=dir(filename);
    nii=struct('Filename',which(filename),...
               'Filemoddate',fileinfo.date,...
               'Filesize',fileinfo.bytes,...
               'Version','NIfTI1',...
               'Description',deblank(char(header.hdr.descrip)),...
               'ImageSize',header.hdr.dim(2:header.hdr.dim(1)+1),...
               'PixelDimensions',header.hdr.pixdim(2:header.hdr.dim(1)+1),...
               'Datatype',header.datatype,...
               'BitsPerPixel',header.hdr.bitpix,...
               'SpaceUnits',niicodemap('unit',bitand(header.hdr.xyzt_units, 7)),...
               'TimeUnits',niicodemap('unit',bitand(header.hdr.xyzt_units, 56)),...
               'AdditiveOffset',header.hdr.scl_inter,...
               'MultiplicativeScaling',header.hdr.scl_slope,...
               'TimeOffset',header.hdr.toffset,...
               'SliceCode',niicodemap('slicetype',header.hdr.slice_code),...
               'FrequencyDimension',bitand(header.hdr.dim_info,7),...
               'PhaseDimension',bitand(bitshift(header.hdr.dim_info,-3),7),...
               'SpatialDimension',0,...
               'DisplayIntensityRange',[header.hdr.cal_min,header.hdr.cal_max],...
               'TransformName',0,...
               'Transform',0,...
               'Qfactor',header.hdr.pixdim(1),...
               'raw',header.hdr ...
               );
    if(header.hdr.sizeof_hdr==540)
        nii.Version='NIfTI2';
    end
    if(header.hdr.sform_code>0)
        nii.TransformName='Sform';
        Aaffine=[header.hdr.srow_x;header.hdr.srow_y;header.hdr.srow_z]';
        Aaffine(4,4)=1;
    elseif(header.hdr.qform_code>0)
        nii.TransformName='Qform';
        b=header.hdr.quatern_b;
        c=header.hdr.quatern_c;
        d=header.hdr.quatern_d;
        a=sqrt(1.0-(b*b+c*c+d*d));
        R=[a*a+b*b-c*c-d*d   2*b*c-2*a*d       2*b*d+2*a*c     
           2*b*c+2*a*d       a*a+c*c-b*b-d*d   2*c*d-2*a*b     
           2*b*d-2*a*c       2*c*d+2*a*b       a*a+d*d-c*c-b*b ];
        if(det(R)==0)
            Aaffine=[R [nii0.hdr.qoffset_x,nii0.hdr.qoffset_y,nii0.hdr.qoffset_z]']';
        else
            Aaffine=[R*diag([header.hdr.pixdim(2:3),header.hdr.pixdim(1)*header.hdr.pixdim(4)]) ...
                  [nii0.hdr.qoffset_x,nii0.hdr.qoffset_y,nii0.hdr.qoffset_z]']';
        end
        Aaffine(4,4)=1;
    else
        nii.TransformName='Old';
        Aaffine=diag(header.hdr.pixdim(2:4));
        Aaffine(4,4)=1;
    end
    if(exist('Aaffine','var'))
        if(exist('affine3d'))
            nii.Transform=affine3d(Aaffine);
        else
            nii.Transform=Aaffine;
        end
    else
        nii.Transform=diag([1,1,1,1]);
    end
catch ME
    rethrow(ME);
end

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
