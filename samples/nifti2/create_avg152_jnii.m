% addpath('../../lib/matlab')

dat=nii2jnii('avg152T1_LR_nifti2.nii.gz')
dat.NIFTIHeader

tic; savejnifti(dat,'avg152T1_LR_nifti2.bnii'); toc
%tic; savejnifti(dat,'avg152T1_LR_nifti2.jnii'); toc % about 29MB before compression
tic; savejnifti(dat,'avg152T1_LR_nifti2_zlib.bnii','compression','zlib'); toc
tic; savejnifti(dat,'avg152T1_LR_nifti2_zlib.jnii','compression','zlib'); toc
if(exist('zmat','file'))
   tic; savejnifti(dat,'avg152T1_LR_nifti2_lzma.bnii','compression','lzma'); toc
   tic; savejnifti(dat,'avg152T1_LR_nifti2_lzma.jnii','compression','lzma'); toc
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/fangq/zmat')
end