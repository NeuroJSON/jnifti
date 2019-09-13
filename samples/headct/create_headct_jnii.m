% addpath('../../lib/matlab')

dat=nii2jnii('headct.nii.gz')
dat.NIFTIHeader

tic; savejnifti(dat,'headct.bnii'); toc
%tic; savejnifti(dat,'headct.jnii'); toc % about 29MB before compression
tic; savejnifti(dat,'headct_zlib.bnii','compression','zlib'); toc
tic; savejnifti(dat,'headct_zlib.jnii','compression','zlib'); toc
if(exist('zmat','file'))
   tic; savejnifti(dat,'headct_lzma.bnii','compression','lzma'); toc
   tic; savejnifti(dat,'headct_lzma.jnii','compression','lzma'); toc
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/fangq/zmat')
end