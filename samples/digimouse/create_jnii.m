load digimouse.mat

jnii=digimouse;

tic;savejnifti(jnii,'digimouse.bnii');toc
tic;savejnifti(jnii,'digimouse_zlib.bnii','compression','zlib');toc
tic;savejnifti(jnii,'digimouse_zlib.jnii','compression','zlib');toc
if(exist('zmat','file'))
   tic;savejnifti(jnii,'digimouse_lzma.bnii','compression','lzma');toc
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/NeuroJSON/zmat')
end

tic;newjnii=loadjnifti('digimouse_zlib.bnii');toc
