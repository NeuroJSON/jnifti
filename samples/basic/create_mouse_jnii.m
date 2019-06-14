load mouse_head.mat
bvol=uint8(volimage);
jnii=jnifticreate(uint8(bvol),'Name','Mouse Head','Description','Binary mask of a mouse-head scan');

saveubjson('',jnii,'FileName','mousehead_gzip.bnii','compression','gzip');
saveubjson('',jnii,'FileName','mousehead.jnii');
saveubjson('',jnii,'FileName','mousehead.bnii');
savejson('',jnii,'FileName','mousehead.jnii');
savejson('',jnii,'FileName','mousehead_lzma.jnii','compression','lzma');
