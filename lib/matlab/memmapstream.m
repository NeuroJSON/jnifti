function mapstr=memmapstream(bytes, dict)

if(nargin<2)
   error('must provide bytes and dict as inputs');
end

if(~ischar(bytes) && ~isa(bytes,'int8') && ~isa(bytes,'uint8') || isempty(bytes))
   error('first input, bytes, must be a char-array or uint8/int8 vector');
end

if(~iscell(dict) || size(dict,2)<3 || size(dict,1)==0 || ~ischar(dict{1,1}))
   error('second input, dict, must be a 3-column cell array, in a format described by the memmapfile Format field.');
end

bytes=bytes(:);

datatype=struct('int8',1,'int16',2,'int32',4,'int64',8,'uint8',1,'uint16',2,'uint32',4,'uint64',8,'single',4,'double',8,'logical',1);

mapstr=struct();
len=1;
for i=1:size(dict,1)
    bytelen=datatype.(dict{i,1})*prod(dict{i,2});
    mapstr.(dict{i,3})=reshape(typecast(bytes(len:bytelen+len-1),dict{i,1}),dict{i,2});
    len=len+bytelen;
end