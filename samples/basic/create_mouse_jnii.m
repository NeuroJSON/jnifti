load mouse_head.mat
bvol=uint8(volimage);
jnii=jnifticreate(uint8(bvol),'Name','Mouse Head','Description','Binary mask of a mouse-head scan');

savejnifti(jnii,'mousehead.jnii');
savejnifti(jnii,'mousehead_zlib.jnii','compression','zlib');
savejnifti(jnii,'mousehead_gzip.bnii','compression','gzip');
savejnifti(jnii,'mousehead.bnii');
if(exist('zmat','file'))
   savejnifti(jnii,'mousehead_lzma.jnii','compression','lzma');
else
   warning('To save lzma-compressed JNIfTI files (smaller file size), please download the ZMat Toolbox from http://github.com/fangq/zmat')
end
