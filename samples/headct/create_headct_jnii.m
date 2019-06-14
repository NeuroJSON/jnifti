% addpath('../../lib/matlab')
if(exist('ct.nii.gz','file') && ~exist('ct.nii','file'))
    finput=fopen('ct.nii.gz','rb');
    input=fread(finput,inf,'uint8=>uint8');
    fclose(finput);

    fid=fopen('ct.nii','wb');
    gzdata=gzipdecode(input);
    fwrite(fid,gzdata);
    fclose(fid);
end

dat=nii2jnii('ct.nii')
dat.NIFTIHeader

tic; nii2jnii('ct.nii','ct.bnii'); toc
%tic; nii2jnii('ct.nii','ct.jnii'); toc % about 29MB before compression
tic; nii2jnii('ct.nii','ct_zlib.bnii','compression','zlib'); toc
tic; nii2jnii('ct.nii','ct_lzma.bnii','compression','lzma'); toc
tic; nii2jnii('ct.nii','ct_zlib.jnii','compression','zlib'); toc
tic; nii2jnii('ct.nii','ct_lzma.jnii','compression','lzma'); toc
