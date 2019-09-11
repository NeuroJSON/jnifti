% addpath('../../lib/matlab')

dat=nii2jnii('headct.nii.gz')
dat.NIFTIHeader

tic; nii2jnii('headct.nii','headct.bnii'); toc
%tic; nii2jnii('headct.nii','headct.jnii'); toc % about 29MB before compression
tic; nii2jnii('headct.nii','headct_zlib.bnii','compression','zlib'); toc
tic; nii2jnii('headct.nii','headct_zlib.jnii','compression','zlib'); toc
if(exist('zmat','file'))
   tic; nii2jnii('headct.nii','headct_lzma.bnii','compression','lzma'); toc
   tic; nii2jnii('headct.nii','headct_lzma.jnii','compression','lzma'); toc
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/fangq/zmat')
end