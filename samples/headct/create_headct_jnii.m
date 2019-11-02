% addpath('../../lib/matlab')

dat=nii2jnii('headct.nii.gz')
dat.NIFTIHeader

tic; savejnifti(dat,'headct.bnii'); info=dir('headct.bnii');
fprintf(1,'Saving Binary JNifTI (raw):\t Saving: t=%f s\tSize: %6.2f kB\tLoadig: \t',toc, info.bytes/1024);
tic; jnii=loadjnifti('headct.bnii'); 
fprintf(1,'t=%f s\n',toc);

%tic; savejnifti(dat,'headct.jnii'); info=dir('headct.jnii');
% fprintf(1,'Saving Text JNifTI: t=%f s\n',toc); % about 29MB before compression

tic; savejnifti(dat,'headct_zlib.bnii','compression','zlib'); info=dir('headct_zlib.bnii');
fprintf(1,'Saving Binary JNifTI (zlib):\t Saving: t=%f s\tSize: %6.2f kB\tLoadig: \t',toc, info.bytes/1024);
tic; jnii=loadjnifti('headct_zlib.bnii'); 
fprintf(1,'t=%f s\n',toc);

tic; savejnifti(dat,'headct_zlib.jnii','compression','zlib'); info=dir('headct_zlib.jnii');
fprintf(1,'Saving Text JNifTI (zlib):\t Saving: t=%f s\tSize: %6.2f kB\tLoadig: \t',toc, info.bytes/1024);
tic; jnii=loadjnifti('headct_zlib.jnii'); 
fprintf(1,'t=%f s\n',toc);

if(exist('zmat','file'))
   tic; savejnifti(dat,'headct_lzma.bnii','compression','lzma'); info=dir('headct_lzma.bnii');
   fprintf(1,'Saving Binary JNifTI (lzma):\t Saving: t=%f s\tSize: %6.2f kB\tLoadig: \t',toc, info.bytes/1024);
   tic; jnii=loadjnifti('headct_lzma.bnii'); 
   fprintf(1,'t=%f s\n',toc);
   
   tic; savejnifti(dat,'headct_lzma.jnii','compression','lzma'); info=dir('headct_lzma.jnii');
   fprintf(1,'Saving Text JNifTI (lzma):\t Saving: t=%f s\tSize: %6.2f kB\tLoadig: \t',toc, info.bytes/1024);
   tic; jnii=loadjnifti('headct_lzma.jnii'); 
   fprintf(1,'t=%f s\n',toc);
   
   tic; savejnifti(dat,'headct_lz4.bnii','compression','lz4'); info=dir('headct_lz4.bnii');
   fprintf(1,'Saving Binary JNifTI (lz4):\t Saving: t=%f s\tSize: %6.2f kB\tLoadig: \t',toc, info.bytes/1024);
   tic; jnii=loadjnifti('headct_lz4.bnii'); 
   fprintf(1,'t=%f s\n',toc);
   
   tic; savejnifti(dat,'headct_lz4.jnii','compression','lz4'); info=dir('headct_lz4.jnii');
   fprintf(1,'Saving Text JNifTI (lz4):\t Saving: t=%f s\tSize: %6.2f kB\tLoadig: \t',toc, info.bytes/1024);
   tic; jnii=loadjnifti('headct_lz4.jnii'); 
   fprintf(1,'t=%f s\n',toc);
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/fangq/zmat')
end
