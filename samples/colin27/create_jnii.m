load colin27.mat

jnii=jnifticreate(uint8(colin27),'Name','Colin27','Description','Colin27 segmentation, processed by Qianqian Fang');

saveubjson('',jnii,'FileName','colin27.bnii');
saveubjson('',jnii,'FileName','colin27_zlib.bnii','compression','zlib');
% saveubjson('',jnii,'FileName','colin27_lzma.bnii','compression','lzma');
savejson(  '',jnii,'FileName','colin27_zlib.jnii','compression','zlib');

newjnii=loadubjson('colin27_zlib.bnii')