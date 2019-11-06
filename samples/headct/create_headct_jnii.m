function create_headct_jnii
    if(~exist('nii2jnii','file') || ~exist('zmat','file') )
            error('you must install JNIfTI toolbox https://github.com/fangq/jnifti and ZMat toolbox:https://github.com/fangq/zmat');
    end
    dat=nii2jnii('headct.nii.gz');
    dat.NIFTIHeader
    zipmethod={'','zlib','gzip','lzma','lz4','lz4hc'};
    runbench=@(z) arrayfun(@(x) runone(dat,z,x),'jb','uniformoutput',false);
    cellfun(runbench,zipmethod);
end

function runone(dat,z,ext) 
    if(isempty(z) && ext=='j') return; end
    fn=sprintf('headct_%s.%snii',z,ext);
    tic;savejnifti(dat,fn,'compression',z);t1=toc;
    tic;loadjnifti(fn);t2=toc;
    info=dir(fn); t3=info.bytes;
    fprintf(1,'Saving %s:\t Saving: t=%f s\tLoadig: \t%f s\tSize: %6.2f kB\n',fn,t1,t2,t3/1024);pause(0.001);
end