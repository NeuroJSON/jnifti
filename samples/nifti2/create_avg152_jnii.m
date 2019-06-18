% addpath('../../lib/matlab')
if(exist('avg152T1_LR_nifti2.nii.gz','file') && ~exist('avg152T1_LR_nifti2.nii','file'))
    finput=fopen('avg152T1_LR_nifti2.nii.gz','rb');
    input=fread(finput,inf,'uint8=>uint8');
    fclose(finput);

    fid=fopen('avg152T1_LR_nifti2.nii','wb');
    gzdata=gzipdecode(input);
    fwrite(fid,gzdata);
    fclose(fid);
end

dat=nii2jnii('avg152T1_LR_nifti2.nii')
dat.NIFTIHeader

tic; nii2jnii('avg152T1_LR_nifti2.nii','avg152T1_LR_nifti2.bnii'); toc
%tic; nii2jnii('avg152T1_LR_nifti2.nii','avg152T1_LR_nifti2.jnii'); toc % about 29MB before compression
tic; nii2jnii('avg152T1_LR_nifti2.nii','avg152T1_LR_nifti2_zlib.bnii','compression','zlib'); toc
tic; nii2jnii('avg152T1_LR_nifti2.nii','avg152T1_LR_nifti2_zlib.jnii','compression','zlib'); toc
if(exist('zmat')==3)
   tic; nii2jnii('avg152T1_LR_nifti2.nii','avg152T1_LR_nifti2_lzma.bnii','compression','lzma'); toc
   tic; nii2jnii('avg152T1_LR_nifti2.nii','avg152T1_LR_nifti2_lzma.jnii','compression','lzma'); toc
end