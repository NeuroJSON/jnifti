load colin27.mat

jnii=jnifticreate(uint8(colin27),'Name','Colin27','Description','Colin27 segmentation, processed by Qianqian Fang');

savejnifti(jnii,'colin27.bnii');
savejnifti(jnii,'colin27_zlib.bnii','compression','zlib');
savejnifti(jnii,'colin27_zlib.jnii','compression','zlib');
if(exist('zmat','file'))
   savejnifti(jnii,'colin27_lzma.bnii','compression','lzma');
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/fangq/zmat')
end

newjnii=loadjnifti('colin27_zlib.bnii')