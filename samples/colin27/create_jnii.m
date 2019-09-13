load colin27.mat

jnii=jnifticreate(uint8(colin27),'Name','Colin27','Description','Colin27 segmentation, processed by Qianqian Fang');

tic;savejnifti(jnii,'colin27.bnii');toc
tic;savejnifti(jnii,'colin27_zlib.bnii','compression','zlib');toc
tic;savejnifti(jnii,'colin27_zlib.jnii','compression','zlib');toc
if(exist('zmat','file'))
   tic;savejnifti(jnii,'colin27_lzma.bnii','compression','lzma');toc
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/fangq/zmat')
end

tic;newjnii=loadjnifti('colin27_zlib.bnii');toc