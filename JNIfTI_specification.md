JNIfTI: a JSON/binary JSON extension to the NIfTI-1/2 formats
============================================================

- **Copyright**: (C) 2019-2025 Qianqian Fang <q.fang at neu.edu>, 
                     2020  Edward Xu <xu.ed at northeastern.edu>
- **License**: Apache License, Version 2.0
- **Version**: V1 (Draft-3.preview)
- **URL**: https://neurojson.org/jnifti/draft2
- **Status**: Draft-3 is a work-in-progress
- **Development**: https://github.com/NeuroJSON/jnifti
- **Abstract**:

> This specification defines the JNIfTI standard format. The JNIfTI format
allows one to store and extend the widely used NIfTI format (.nii) using JavaScript
Object Notation (JSON) [RFC4627] and binary JSON serialization methods.
It loss-lessly maps all NIfTI-1 and NIfTI-2 headers and data structures to
a human-readable JSON-based wrapper. Use of JSON and JNIfTI formats to store
NIfTI data makes it possible to rapidly index, exchange, and query large amount
of NIfTI datasets and metadata using modern database engines where JSON is used
as the underlying data exchange format. With the extension of JData annotations,
JNIfTI also permits optional hierarchical data storage, image data grouping,
various data compression codecs, filters, streaming and encryption.


## Table of Content

- [Introduction](#introduction)
  * [Background](#background)
  * [JNIfTI specification overview](#jnifti-specification-overview)
- [Grammar](#grammar)
- [JNIfTI Keywords](#jnifti-keywords)
  * [NIFTIHeader](#niftiheader)
    + [DataType (NIFTI-1 header: datatype)](#datatype-nifti-1-header-datatype)
    + [Dim (NIFTI-1 header: dim)](#dim-nifti-1-header-dim)
    + [DimInfo (NIFTI-1 header: dim_info)](#diminfo-nifti-1-header-dim_info)
    + [Orientation (NIFTI-1 header: pixdim[0])](#orientation-nifti-1-header-pixdim0)
    + [Unit (NIFTI-1 header: xyzt_units)](#unit-nifti-1-header-xyzt_units)
    + [Intent (NIFTI-1 header: intent_code)](#intent-nifti-1-header-intent_code)
    + [SliceType (NIFTI-1 header: slice_code)](#slicetype-nifti-1-header-slice_code)
    + [QForm/SForm (NIFTI-1 header: qform_code/sform_code)](#qformsform-nifti-1-header-qform_codesform_code)
    + [NIIFormat (NIFTI-1 header: magic)](#niiformat-nifti-1-header-magic)
    + [NIIHeaderSize (NIFTI-1 header: sizeof_hdr)](#niiheadersize-nifti-1-header-sizeof_hdr)
    + [NIIByteOffset (NIFTI-1 header: vox_offset)](#niibyteoffset-nifti-1-header-vox_offset)
    + [Other depreciated subfields](#other-depreciated-subfields)
  * [NIFTIData](#niftidata)
    + [Array form](#array-form)
    + [Structure form](#structure-form)
    + [Composite data types](#composite-data-types)
      - [complex64](#complex64)
      - [complex128](#complex128)
      - [rgb24](#rgb24)
      - [rgba32](#rgba32)
      - [double128](#double128)
      - [complex256](#complex256)
  * [NIFTIExtension](#niftiextension)
- [Data Organization and Grouping](#data-organization-and-grouping)
- [Recommended File Specifiers](#recommended-file-specifiers)
- [Summary](#summary)


Introduction
------------

### Background


JNIfTI has been developed as a more widely accessible extension to the 
[NIFTI](https://nifti.nimh.nih.gov/) format, a widely supported binary data 
format for storing spatiotemporal neuroimaging data. It provides a modernized, 
easy-to-use container for serializing array-formatted imaging and 
time series data obtained from neuroanatomical or functional scans. The original 
NIFTI format [(NIFTI-1)](https://nifti.nimh.nih.gov/nifti-1/) 
was derived from another widely supported medical image format, 
[Analyze 7.5](https://rportal.mayo.edu/bir/ANALYZE75.pdf), 
and  extended the Analyze 7.5 metadata to a 352-byte binary header (containing 
a 348-byte header for the metadata storage and 4 bytes
of extension flags). In 2011, the NIFTI format was upgraded to 
[NIFTI-2](https://nifti.nimh.nih.gov/nifti-2/), consequently permitting
the storage of large sized imaging data by using 64-bit integers to store
the image dimension data in place of the original 16-bit.

Although the NIfTI format is quite simple and allows for easy data parsing 
and storage, it suffers from a number of drawbacks, namely a fixed header 
size, rigid and static list of metadata fields, and inflexibility towards 
storing only array-valued neuroimaging data. This constitutes a major 
challenge towards extending the NIfTI format to store additional metadata 
records or complex auxiliary data, such as for physiological monitoring 
or multi-modality imaging. Furthermore, due to the rigidity of the NIfTI 
header, extending from Analyze 7.5 to NIfTI-1, and subsequently NIfTI-2, 
rendered the prior data formats incompatible with newer parsers and softwares. 
This has become a significant burden towards the recovery and reusability 
of data acquired under the previous data formats. To add to this, the 
NIfTI formats consist only of a binary interface and thus are not directly 
human-readable, thus further complicating this task.

Over the past few years, [JavaScript Object Notation](https://json.org) 
(JSON) has become ubiquitously recognized among the Internet community for its 
ability to store complex data, excellent portability, and human-readability. 
The subsequent introduction and widespread adoption of a range of binary 
JSON-like format, such as [UBJSON](https://ubjson.org), 
[Binary JData (BJData)](https://neurojson.org/bjdata), 
[MessagePack](https://msgpack.org/) and [CBOR](https://cbor.io), 
have added complementary features such as support for typed data, smaller file 
sizes, and faster processing speeds as well. The 
[JData specification](https://github.com/NeuroJSON/jdata/blob/master/JData_specification.md) 
capitalizes upon the strengths of these data interchange formats and
provides the foundation for serializing complex hierarchical data using
JSON/BJData constructs. This has then enabled the definition of language- 
and library-neutral neuroimaging data representations using the simple and 
extensible constructs from JSON and BJData syntax.


### JNIfTI specification overview

JNIfTI is an extensible framework for storing neuroimaging and time series 
data using the JData representation, with a syntax compatible with widely- 
used JSON and Binary JData/BJData file formats. JNIfTI directly addresses 
the limitations currently faced by the NIfTI formats by providing flexible 
and rich metadata support, fast and efficient storage of typed numerical 
array data, versatile accommodation for both array- and non-array-formed 
auxiliary or multi-modality data entries, flexible data grouping, and 
internal data compression. In doing so, the JNIfTI framework establishes 
the groundwork for more robust practices of data sharing and reusability, 
as well as easy integration and automation.

The purpose of this document is to

- define a 1-to-1 mapping between the existing NIFTI-1 and NIFTI-2 headers 
  to a JSON/BJData-based flexible metadata header structure, so that all NIFTI
  formatted metadata can be losslessly stored using JNIfTI
- define dedicated data containers to losslessly convert and store all NIFTI 
  formatted neuroimaging data arrays, and provide examples demonstrating the use of JData-enabled 
  features for reducing file sizes, enhancing readability, and improving organization
- define a set of human-readable and standardized string values to directly 
  represent the meaning of data as alternative to NIFTI-1/2 numerical coded values
- establish a set of flexible mechanisms to extend the capability of the 
  format to accommodate additional physiological, anatomical and multi-modal data

In the following sections, we will clarify basic JNIfTI grammar and define 
JNIfTI header and data containers. The additional features and extension 
mechanisms will also be discussed and exemplified.
 


Grammar
------------------------

All JNIfTI files are JData specification compliant. As with JData, JNIfTI 
provides both a text-based format using JSON serialization and a binary format 
based upon the BJData serialization scheme.The two forms can be converted 
from one to another.

Briefly, the text-based JNIfTI is a valid JSON file with an extension to 
support concatenated JSON objects; the binary-format JNIfTI is a valid BJData 
file with extended syntax to support N-D arrays. Please refer to the JData 
specification for these definitions.

Each NIFTI-1/2 file carries a numerical N-dimensional (N-D, `N=1-7`) array as the 
primary data payload. According to the JData specification, N-D arrays have 
two equivalent and interchangeable storage forms - the direct storage format 
and the annotated storage format. 

For example, one can store a 1-D or 2-D array using the direct storage format as
```
 "jnifti_keyword": [v1,v2,...,vn]
```
or
```
 "jnifti_keyword": [
    [v11,v12,...,v1n],
    [v21,v22,...,v2n],
    ...
    [vm1,vm2,...,vmn]
  ]
```
or using the "annotated storage" format as
```
 "jnifti_keyword": {
       "_ArrayType_": "typename",
       "_ArraySize_": [N1,N2,N3,...],
       "_ArrayData_": [v1,v2,v3,...]
  }
```
The direct storage format and the annotated storage format are functionally 
equivalent. While we primarily describe data storage in the context of the direct 
format below, it is applicable to the annotated format as well. We also note that
any valid JSON formatted data structure can be converted into a binary form using the
rules defined in the [Binary JData specification](https://neurojson.org/bjdata), 
which was extended from [UBJSON specification (Draft 12)](https://ubjson.org).


JNIfTI Keywords
------------------------

JNIfTI uses three dedicated data containers to store NIFTI-1/2 compatible data:

* **`NIFTIHeader`**: a named structure to store all defined NIFTI-1/2 header
  metadata and to allow for additional user-defined  metadata or headers,
* **`NIFTIData`**: an array or structure object to store the primary neuroimaging 
  data. When using the array-form, it can support an arbitrary number of dimensions,
  with the length of each dimension stored as an integer of up to 64bit.
* **`NIFTIExtension`**: (optional) an array of JData `"_ByteStream_"` objects to store the
  NIFTI-1 extension buffers (for compatibility purposes)
  
These three data containers can appear at any level in a JData tree. `NIFTIData` is the 
only required data object if a JNIfTI file contains a neuroimaging dataset. 
When a `NIFTIHeader` field is stored under the same parent node as a `NIFTIData` object, 
the `NIFTIHeader` record serves as the metadata for the `NIFTIData` object. 
The optional `NIFTIExtension` is strictly used for compatibility purpose only, 
and is grouped with the `NIFTIHeader` and `NIFTIData` records if they appear under the 
same node.

When multiple `NIFTIHeader`/`NIFTIData`/`NIFTIExtension` objects need to be stored under
the same parent node in a JData tree, they must be differentiated by attaching a 
name, such as `NIFTIHeader(name)`, `NIFTIData(name)` and `NIFTIExtension(name)`. Objects
of the same name shall be grouped and processed together. JNIfTI keywords
should not be repeated more than once (with the same name or without a name) under the same
parent node as creates an invalid JSON construct.

### NIFTIHeader

The JNIfTI format use a structure named `"NIFTIHeader"` to store NIFTI-compatible
header information.

In the below table, we define a 1-to-1 mapping from NIFTI-1/2 headers to the
corresponding JNIfTI `NIFTIHeader` self-explanatory subfields

***Table 1. A mapping table for NIFTI-1/2 headers and JNIfTI NIFTIHeader structure***

| NIFTI-1| NIFTI-2|     Headers      |          Meanings             |   JNIfTI NIFTIHeader container	     |
|--------|--------|------------------|-------------------------------|---------------------------------------|
|`struct`|`struct`|` nifti_1_header{`|                               |`"NIFTIHeader": { 		    `|
|` int  `|` int  `|` sizeof_hdr;    `|  **NIFTI-1/2: 348/540** 	     |`    "NIIHeaderSize": <i>,	    `|
|` char `|   -    |` data_type[10]; `|  **++UNUSED++**  	     |`    "A75DataTypeName":   "s",  `|
|` char `|   -    |` db_name[18];   `|  **++UNUSED++**  	     |`    "A75DBName": "s",		    `|
|` int  `|   -    |` extents;	    `|  **++UNUSED++**  	     |`    "A75Extends": <i>,		    `|
|` short`|   -    |` session_error; `|  **++UNUSED++**  	     |`    "A75SessionError": <i>,	    `|
|` char `|   -    |` regular;	    `|  **++UNUSED++**  	     |`    "A75Regular": <i>,		    `|
|` char `|` char `|` dim_info;      `|  **MRI slice ordering**       |`    "DimInfo" : {		    `|
|        | 	  | 		     |	 			     |`        "Freq": <i>,                 `|
|        |     	  | 		     |	 			     |`        "Phase": <i>,                `|
|        | 	  | 		     |	 			     |`        "Slice": <i>                 `|
|        | 	  | 		     |	 			     |`     },  			    `|
|` short`|` int64`|` dim[8];	    `|  **Data array dimensions**    |`    "Dim": [dim[1],dim[2],...],      `|
|` float`|`double`|` intent_p1 ;    `|  **1st intent parameter**     |`    "Param1": <f>,		    `|
|` float`|`double`|` intent_p2 ;    `|  **2nd intent parameter**     |`    "Param2": <f>,		    `|
|` float`|`double`|` intent_p3 ;    `|  **3rd intent parameter**     |`    "Param3": <f>,		    `|
|` short`|` int  `|` intent_code ;  `|  **NIFTI_INTENT_\* code**     |`    "Intent": <i>\|"s",		    `|
|` short`|` short`|` datatype;      `|  **Defines data type**	     |`    "DataType": <i>\|"s",	    `|
|` short`|` short`|` bitpix;	    `|  **Number bits/voxel**	     |`    "BitDepth": <i>,		    `|
|` short`|` int  `|` slice_start;   `|  **First slice index**	     |`    "FirstSliceID": <i>, 	    `|
|` float`|`double`|` pixdim[8];     `|  **Grid spacings**	     |`    "VoxelSize":[pixdim[1],pixdim[2],...],`|
|        | 	  | 		     |  **+x direction meaning**     |`    "Orientation": { "x": "s", 	    `|
|        | 	  | 		     |  **+y direction meaning**     |`        "y": "s",		    `|
|        | 	  | 		     |  **+z direction meaning**     |`        "z": "s" 		    `|
|        | 	  | 		     |*RAS or LAS base on pixdim[0]* |`     },  			    `|
|` float`|`double`|` vox_offset;    `|  **Offset into .nii file**    |`    "NIIByteOffset": <f>,	    `|
|` float`|`double`|` scl_slope ;    `|  **Data scaling: slope**      |`    "ScaleSlope": <f>,		    `|
|` float`|`double`|` scl_inter ;    `|  **Data scaling: offset**     |`    "ScaleOffset": <f>,  	    `|
|` short`|` int  `|` slice_end;     `|  **Last slice index**	     |`    "LastSliceID": <i>,  	    `|
|` char `|` int  `|` slice_code ;   `|  **Slice timing order**       |`    "SliceType": <i>\|"s",	    `|
|` char `|` int  `|` xyzt_units ;   `|  **Units of pixdim[1..4]**    |`    "Unit":{"L":<i>\|"s","T":<i>\|"s"},`|
|` float`|` float`|` cal_max;	    `|  **Max display intensity**    |`    "MaxIntensity": <f>, 	    `|
|` float`|` float`|` cal_min;	    `|  **Min display intensity**    |`    "MinIntensity": <f>, 	    `|
|` float`|` float`|` slice_duration;`|  **Time for 1 slice**	     |`    "SliceTime": <f>,		    `|
|` float`|` float`|` toffset;	    `|  **Time axis shift**	     |`    "TimeOffset": <f>,		    `|
|` int  `|   -    |` glmax;	    `|  **++UNUSED++**  	     |`    "A75GlobalMax": <i>,             `|
|` int  `|   -    |` glmin;	    `|  **++UNUSED++**  	     |`    "A75GlobalMin": <i>, 	    `|
|` char `|` char `|` descrip[80];   `|  **Data description**	     |`    "Description": "s",  	    `|
|` char `|` char `|` aux_file[24];  `|  **Auxiliary filename**       |`    "AuxFile": "s",		    `|
|` short`|` int  `|` qform_code ;   `|  **NIFTI_XFORM_\* code**      |`    "QForm": <i>\|"s",		    `|
|` short`|` int  `|` sform_code ;   `|  **NIFTI_XFORM_\* code**      |`    "SForm": <i>\|"s",		    `|
|` float`|`double`|` quatern_b ;    `|  **Quaternion b param**       |`    "Quatern": { "b"=<f>,	    `|
|` float`|`double`|` quatern_c ;    `|  **Quaternion c param**       |`        "c": <f>,		    `|
|` float`|`double`|` quatern_d ;    `|  **Quaternion d param**       |`        "d": <f> 		    `|
|        | 	  | 		     |	 			     |`     },  			    `|
|` float`|`double`|` qoffset_x ;    `|  **Quaternion x shift**       |`    "QuaternOffset":{ "x": <f>,	    `|
|` float`|`double`|` qoffset_y ;    `|  **Quaternion y shift**       |`        "y": <f>,		    `|
|` float`|`double`|` qoffset_z ;    `|  **Quaternion z shift**       |`        "z": <f> 		    `|
|        | 	  | 		     |	 			     |`     },  			    `|
|` float`|`double`|` srow_x[4] ;    `|  **1st row affine transform** |`    "Affine": [ [<f>,<f>,<f>,<f>],   `|
|` float`|`double`|` srow_y[4] ;    `|  **2nd row affine transform** |`        [<f>,<f>,<f>,<f>],	    `|
|` float`|`double`|` srow_z[4] ;    `|  **3rd row affine transform** |`        [<f>,<f>,<f>,<f>]	    `|
|        | 	  | 		     |	 			     |`    ],				    `|
|` char `|` char `|`intent_name[16];`|  **'name' or meaning of data**|`    "Name" : "s",		    `|
|`char*4`|`char*8`|` magic[] ;      `| **NIFTI-1:"ni1\0" or "n+1\0"**|`    "NIIFormat": "s",		    `|
|        | 	  |`};`		     |	 			     |     			             |
|`struct`|`struct`|`nifti_extender  `|`{char extension[4];};`        |`    "NIFTIExtension": [<i>,<i>,<i>,<i>],`|
|        | 	  |     	     |			             |`    <...>			    `|
|        | 	  | 	   	     |			             |`}				    `|
 
Notations from the above table are explained below

* `<i>` represents an integer value (signed integer of 8, 16, 32 or 64bit)
* `<f>` represents an numerical value (including integers, 32bit and 64bit floating point numbers)
* `"s"` represents a UTF-8 encoded string of arbitrary length
* `[...]` represents a vector of variable length
* `<...>` represents (optional) additional subfields for user-defined header or future extensions
* `<i>|"s"` represents alternative forms, in this example, the field can be either an integer or a string


To convert a NIFTI-1/2 header to the JNIfTI `NIFTIHeader` structure without 
sacrificing accuracy, the storage type byte length of the `NIFTIHeader` subfields 
be of equal or greater value to their original NIfTI header counterpart; in 
the case of a string value, the new string must be of the same 
or longer length to store the entire original string value.

If the NIFTI header field contains an array, the converted `NIFTIHeader` subfield shall also
contain an array object sorted in the same order.

Not all `"NIFTIHeader"` subfields shall present. However, if any of the subfields in 
the NIFTI-1/2 header carry meaningful data, the corresponding subfield in the `NIFTIHeader` 
must present. The order of the `NIFTIHeader` subfields is not required.

Mapping in the reverse direction, i.e. from JNIfTI to NIFTI-1/2, is not guaranteed to be lossless.

#### DataType (NIFTI-1 header: `datatype`)

To enhance the readability of the header, we allow the use of a string to 
represent data type (i.e. the `DataType` subfield in `NIFTIHeader`) instead 
of an integer code. The below
table maps the NIFTI data type codes to the acceptable data type strings.

***Table 2. A mapping table from NIFTI-1 data types to string-valued JNIfTI data types and 
storage types in BJData***

|  NIFTI-1/2 Data Types   | NIFTI Code  | JNIfTI DataType  |BJData Type|
|-------------------------|-------------|------------------|-----------|
|**unsigned char**        |             |                  |	       |
|`NIFTI_TYPE_UINT8`       |      `2    `|`  "uint8"       `| `U`       |
|**signed short**         |             |                  |	       |
|`NIFTI_TYPE_INT16`       |      `4    `|`  "int16"       `| `I`       |
|**signed int**           |             |                  |	       |
|`NIFTI_TYPE_INT32`       |      `8    `|`  "int32"       `| `l`       |
|**32 bit float**         |             |                  |	       |
|`NIFTI_TYPE_FLOAT32`     |     `16    `|`  "single"      `| `d`       |
|**64 bit complex = 2` `32 bit floats** |     |            |	       |
|`NIFTI_TYPE_COMPLEX64`   |     `32    `|`  "complex64" `\*| `d` (x2)  |
|**64 bit float = double**|             |                  |	       |
|`NIFTI_TYPE_FLOAT64`     |     `64    `|`  "double"      `| `D`       |
|**3x 8 bit bytes**       |             |                  |	       |
|`NIFTI_TYPE_RGB24`       |    `128    `|`  "rgb24"     `\*| `U` (x3)  |
|**signed char**          |             |                  |	       |
|`NIFTI_TYPE_INT8`        |    `256    `|`  "int8"        `| `i`       |
|**unsigned short**       |             |                  |	       |
|`NIFTI_TYPE_UINT16`      |    `512    `|`  "uint16"      `| `u`       |
|**unsigned int**         |             |                  |	       |
|`NIFTI_TYPE_UINT32`      |    `768    `|`  "uint32"      `| `m`       |
|**signed long long**     |             |                  |	       |
|`NIFTI_TYPE_INT64`       |   `1024    `|`  "int64"       `| `L`       |
|**unsigned long long**   |             |                  |	       |
|`NIFTI_TYPE_UINT64`      |   `1280    `|`  "uint64"      `| `M`       |
|**128 bit float = long double** |      |                  |	       |
|`NIFTI_TYPE_FLOAT128`    |   `1536    `|`  "double128" `\*| `U` (x16) |
|**2x 64 bit floats = 128 bit complex** |     |            |	       |
|`NIFTI_TYPE_COMPLEX128`  |   `1792    `|`  "complex128"`\*| `D` (x2)  |
|**2x 128 bit floats = 256 bit complex**|     |            |	       |
|`NIFTI_TYPE_COMPLEX256`  |   `2048    `|`  "complex256"`\*| `U` (x32) |
|**4x 8 bit bytes**       |             |                  |	       |
|`NIFTI_TYPE_RGBA32`      |   `2304    `|`  "rgba32"    `\*| `U` (x4)  |

A "\*" sign in the JNIfTI DataType column indicates that the data is a composite type, and must
be stored using the "annotated" JData format.

#### Dim (NIFTI-1 header: `dim`)

In the NIFTI-1/2 formats, `dim[0]` stores the number of dimensions of the data, and `dim[1]`
to `dim[7]` store the respective dimension of data. In `NIFTIHeader`, we use an array object `Dim` to
store the effective dimension sizes starting from `dim[1]`. The length of `Dim` array
should equal to that of `dim[0]`.

#### DimInfo (NIFTI-1 header: `dim_info`)

In the NIFTI-1/2 formats, the `dim_info` field combines 3 parameters, `freq_dim`, `phase_dim` 
and `slice_dim`, using bit-masks. To enhance readability, we represent each of 
these parameters as explicit subfields in JNIfTI, specifically `"Freq"`, 
`"Phase"` and `"Slice"` inside the `"DimInfo"` 
structure. A fixed order of the 3 subfields is not required.

#### Orientation (NIFTI-1 header: `pixdim[0]`)

The first element in the `pixdim[]` array, i.e. `pixdim[0]` in the NIFTI-1/2 header, 
indicates the handedness of the coordinate system. `pixdim[0]` is assigned a value 
of either 0, indicating a "right-anterior-superior" (RAS) coordinate (+x-axis = 
right, +y-axis = anterior, +z-axis = superior), or 1, representing a 
"left-anterior-superior" (LAS) system.

To enhance readability of JNIfTI, `NIFTIHeader` uses much more intuitive and extended
labels to indicate the orientations of axes. In the `"Orientation"` field, one
can define 3 string-valued subfields, `"x"`, `"y"` and `"z"`, to indicate the direction of 
the positive axis. The allowed values (case-insensitive) are

* `"l"` or `"left"`
* `"r"` or `"right"`
* `"a"` or `"anterior"`
* `"p"` or `"posterior"`
* `"s"` or `"superior"`
* `"i"` or `"inferior"`

For example, an RAS orientation can be indicated by
```
"Orientation" : {"x":"r", "y":"a",  "z":"s"}
```

If this subfield is missing, we assume the same "RAS" default orientation as NIFTI-1/2.


#### Unit (NIFTI-1 header: `xyzt_units`)

The NIFTI-1/2 `xyzt_units` is a combined mask of both space and time.
In JNIfTI, we map it to a structure with at least two subfields:
`"L"` to store spatial units, and `"T"` to store time units. 

Similar to `DataType`, both `L` and `T` allow the use of an integer value, matching
that of the NIFTI-1/2 unit definitions, or a more descriptive string value
to specify the units. The mapping between NIFTI-1/2 units to the string forms
is listed below

***Table 3. A mapping table for NIFTI-1 unit types and string-valued JNIfTI `NIFTIHeader` Unit field***

|          NIFTI-1/2 Unit Types                | JNIfTI Unit  |
|----------------------------------------------|--------------|
|**Unknown Units**                             |              |
|        `NIFTI_UNITS_UNKNOWN 0               `|  `""`        |
|**Length Units**                              |              |
|*NIFTI code for meters*                       |	      |
|        `NIFTI_UNITS_METER   1               `|  `"m"`       |
|*NIFTI code for millimeters*                  |	      |
|        `NIFTI_UNITS_MM      2               `|  `"mm"`      |
|*NIFTI code for micrometers*                  |	      |
|        `NIFTI_UNITS_MICRON  3               `|  `"um"`      |
|**Time Units**                                |              |
|*NIFTI code for seconds*                      |	      |
|        `NIFTI_UNITS_SEC     8               `|  `"s"`       |
|*NIFTI code for milliseconds*                 |	      |
|        `NIFTI_UNITS_MSEC   16               `|  `"ms"`      |
|*NIFTI code for microseconds*                 |	      |
|        `NIFTI_UNITS_USEC   24               `|  `"us"`      |
|**Other Units**                               |              |
|*NIFTI code for Hertz*                        |	      |
|        `NIFTI_UNITS_HZ     32               `|  `"hz"`      |
|*NIFTI code for ppm*                          |	      |
|        `NIFTI_UNITS_PPM    40               `|  `"ppm"`     |
|*NIFTI code for radians per second*           |	      |
|        `NIFTI_UNITS_RADS   48               `|  `"rad/s"`   |


#### Intent (NIFTI-1 header: `intent_code`)

Similar to `DataType`, data intent (i.e. the `Intent` subfield in `NIFTIHeader`) can be represented by a string instead of an integer code. 
The below table maps the NIFTI data intent codes to the acceptable intent strings.


| NIFTI-1/2 Data Intent Type    |Code |JNIfTI Intent String|
|-------------------------------|-----|--------------------|
|  **Unknown data intent**                             | | |
|`NIFTI_INTENT_NONE            `| `0` |  `""`              |
|  **Correlation coefficient R (1 param)**             | | |
|`NIFTI_INTENT_CORREL          `| `2` |  `"corr"`          |
|  **Student t statistic (1 param): p1 = DOF**         | | |
|`NIFTI_INTENT_TTEST           `| `3` |  `"ttest"`         |
|  **Fisher F statistic (2 params)**                   | | |
|`NIFTI_INTENT_FTEST           `| `4` |  `"ftest"`         |
|  **Standard normal (0 params): Density = N(0,1)**    | | |
|`NIFTI_INTENT_ZSCORE          `| `5` |  `"zscore"`        |
|  **Chi-squared (1 param): p1 = DOF**                 | | |
|`NIFTI_INTENT_CHISQ           `| `6` |  `"chi2"`          |
|  **Beta distribution (2 params): p1=a, p2=b**        | | |
|`NIFTI_INTENT_BETA            `| `7` |  `"beta"`          |
|  **Binomial distribution (2 params)**                | | |
|`NIFTI_INTENT_BINOM           `| `8` |  `"binomial"`      |
|  **Gamma distribution (2 params)**                   | | |
|`NIFTI_INTENT_GAMMA           `| `9` |  `"gamma"`         |
|  **Poisson distribution (1 param): p1 = mean**       | | |
|`NIFTI_INTENT_POISSON        `| `10` |  `"poisson"`       |
|  **Normal distribution (2 params)**                  | | |
|`NIFTI_INTENT_NORMAL         `| `11` |  `"normal"`        |
|  **Noncentral F statistic (3 params)**               | | |
|`NIFTI_INTENT_FTEST_NONC     `| `12` |  `"ncftest"`       |
|  **Noncentral chi-squared statistic (2 params)**     | | |
|`NIFTI_INTENT_CHISQ_NONC     `| `13` |  `"ncchi2"`        |
|  **Logistic distribution (2 params)**                | | |
|`NIFTI_INTENT_LOGISTIC       `| `14` |  `"logistic"`      |
|  **Laplace distribution (2 params)**                 | | |
|`NIFTI_INTENT_LAPLACE        `| `15` |  `"laplace"`       |
|  **Uniform distribution: p1=lower end,p2=upper end** | | |
|`NIFTI_INTENT_UNIFORM        `| `16` |  `"uniform"`       |
|  **Noncentral t statistic (2 params)**               | | |
|`NIFTI_INTENT_TTEST_NONC     `| `17` |  `"ncttest"`       |
|  **Weibull distribution (3 params)**                 | | |
|`NIFTI_INTENT_WEIBULL        `| `18` |  `"weibull"`       |
|  **Chi distribution (1 param): p1 = DOF**            | | |
|`NIFTI_INTENT_CHI            `| `19` |  `"chi"`           |
|  **Inverse Gaussian (2 params)**                     | | |
|`NIFTI_INTENT_INVGAUSS       `| `20` |  `"invgauss"`      |
|  **Extreme value type I (2 params)**                 | | |
|`NIFTI_INTENT_EXTVAL         `| `21` |  `"extval"`        |
|  **Data is a 'p-value' (no params)**                 | | |
|`NIFTI_INTENT_PVAL           `| `22` |  `"pvalue"`        |
|  **Data is ln(p-value) (no params)**                 | | |
|`NIFTI_INTENT_LOGPVAL        `| `23` |  `"logpvalue"`     |
|  **Data is log10(p-value) (no params)**              | | |
|`NIFTI_INTENT_LOG10PVAL      `| `24` |  `"log10pvalue"`   |
| **Data is an estimate of some parameter**            | | |
|`NIFTI_INTENT_ESTIMATE     `| `1001` |  `"estimate"`      |
| **Data is an index into a set of labels**            | | |
|`NIFTI_INTENT_LABEL        `| `1002` |  `"label"`         |
| **Data is an index into the NeuroNames labels**      | | |
|`NIFTI_INTENT_NEURONAME    `| `1003` |  `"neuronames"`    |
| **To store an M x N matrix at each voxel**           | | |
|`NIFTI_INTENT_GENMATRIX    `| `1004` |  `"matrix"`        |
| **To store an NxN symmetric matrix at each voxel**   | | |
|`NIFTI_INTENT_SYMMATRIX    `| `1005` |  `"symmatrix"`     |
| **Each voxel is a displacement vector**              | | |
|`NIFTI_INTENT_DISPVECT     `| `1006` |  `"dispvec"`       |
| **Specifically for displacements**                   | | |
|`NIFTI_INTENT_VECTOR       `| `1007` |  `"vector"`        |
| **Any other type of vector**                         | | |
|`NIFTI_INTENT_POINTSET     `| `1008` |  `"point"`         |
| **Each voxel is really a triple**                    | | |
|`NIFTI_INTENT_TRIANGLE     `| `1009` |  `"triangle"`      |
| **Each voxel is a quaternion**                       | | |
|`NIFTI_INTENT_QUATERNION   `| `1010` |  `"quaternion"`    |
| **Dimensionless value - no params**                  | | |
|`NIFTI_INTENT_DIMLESS      `| `1011` |  `"unitless"`      |
| **Each data point is a time series**                 | | |
|`NIFTI_INTENT_TIME_SERIES  `| `2001` |  `"tseries"`       |
| **Each data point is a node index**                  | | |
|`NIFTI_INTENT_NODE_INDEX   `| `2002` |  `"elem"`          |
| **Each data point is an RGB triplet**                | | |
|`NIFTI_INTENT_RGB_VECTOR   `| `2003` |  `"rgb"`           |
| **Each data point is a 4 valued RGBA**               | | |
|`NIFTI_INTENT_RGBA_VECTOR  `| `2004` |  `"rgba"`          |
| **Each data point is a shape value**                 | | |
|`NIFTI_INTENT_SHAPE        `| `2005` |  `"shape"`         |
| **Used by FSL FNIRT**                                                                                     | | |
|`NIFTI_INTENT_FSL_FNIRT_DISPLACEMENT_FIELD            ` | `2006` |  `"fsl_fnirt_displacement_field"`           |
|`NIFTI_INTENT_FSL_CUBIC_SPLINE_COEFFICIENTS            `| `2007` |  `"fsl_cubic_spline_coefficients"`          |
|`NIFTI_INTENT_FSL_DCT_COEFFICIENTS                     `| `2008` |  `"fsl_dct_coefficients"`                   |
|`NIFTI_INTENT_FSL_QUADRATIC_SPLINE_COEFFICIENTS        `| `2009` |  `"fsl_quadratic_spline_coefficients"`      |
| **Used by FSL TOPUP**                                                                                     | | |
|`NIFTI_INTENT_FSL_TOPUP_CUBIC_SPLINE_COEFFICIENTS      `| `2016` |  `"fsl_topup_cubic_spline_coefficients"`    |
|`NIFTI_INTENT_FSL_TOPUP_QUADRATIC_SPLINE_COEFFICIENTS  `| `2017` |  `"fsl_topup_quadratic_spline_coefficients"`|
|`NIFTI_INTENT_FSL_TOPUP_FIELD                          `| `2018` |  `"fsl_topup_field"`                        |


#### SliceType (NIFTI-1 header: `slice_code`)

Similar to `DataType`, the slice type (i.e. the `SliceType` subfield in 
`NIFTIHeader`) can be represented as a string instead of an integer code. 
The below table maps the NIFTI data slice codes to the acceptable slice strings.

|  NIFTI-1/2 Slice Code Name    |Code |JNIfTI SliceType Key|
|-------------------------------|-----|--------------------|
|  **Unknown slice type**                              | | |
|`NIFTI_SLICE_UNKNOWN          `| `0` |  `""`              |
|  **Slice sequential increasing**                     | | |
|`NIFTI_SLICE_SEQ_INC          `| `1` |  `"seq+"`          |
|  **Slice sequential decreasing**                     | | |
|`NIFTI_SLICE_SEQ_DEC          `| `2` |  `"seq-"`          |
|  **Slice alternating increasing**                    | | |
|`NIFTI_SLICE_ALT_INC          `| `3` |  `"alt+"`          |
|  **Slice alternating decreasing**                    | | |
|`NIFTI_SLICE_ALT_DEC          `| `4` |  `"alt-"`          |
|  **Slice alternating increasing type 2**             | | |
|`NIFTI_SLICE_ALT_INC2         `| `5` |  `"alt2+"`         |
|  **Slice alternating decreasing type 2**             | | |
|`NIFTI_SLICE_ALT_DEC2         `| `6` |  `"alt2-"`         |

#### QForm/SForm (NIFTI-1 header: `qform_code/sform_code`)


|  NIFTI-1/2 XForm Code Name    |Code |      JNIfTI QForm/SForm Key         |
|-------------------------------|-----|-------------------------------------|
|  **Arbitrary coordinates**                                            | | |
|`NIFTI_SLICE_UNKNOWN          `| `0` |  `""`                               |
|  **Scanner-based anatomical coordinates**                             | | |
|`NIFTI_XFORM_SCANNER_ANAT     `| `1` |  `"scanner_anat"`                   |
|  **Coordinates aligned to another file's, or to anatomical "truth"**  | | |
|`NIFTI_XFORM_ALIGNED_ANAT     `| `2` |  `"aligned_anat"`                   |
|  **Coordinates aligned to Talairach-Tournoux Atlas**                  | | |
|`NIFTI_XFORM_TALAIRACH        `| `3` |  `"talairach"`                      |
|  **MNI 152 normalized coordinates**                                   | | |
|`NIFTI_XFORM_MNI_152          `| `4` |  `"mni_152"`                        |
|  **Normalized coordinates(for any general standard template space)**  | | |
|`NIFTI_XFORM_TEMPLATE_OTHER   `| `5` |  `"template_other"`                 |

#### NIIFormat (NIFTI-1 header: `magic`)

The `"NIIFormat"` field stores the original NIFTI-1 format identifier, and is designed for 
compatibility purposes only. The use of this field is deprecated.

#### NIIHeaderSize (NIFTI-1 header: `sizeof_hdr`)

The `"NIIHeaderSize"` field stores the original NIFTI-1 header size, and is designed for 
compatibility purposes only. The use of this field is deprecated.

#### NIIByteOffset (NIFTI-1 header: `vox_offset`)

The `"NIIByteOffset"` field stores the original NIFTI-1 voxel data starting position offset, 
and is designed for compatibility purposes only. The use of this field is deprecated.

#### Other depreciated subfields

All Analyze 7.5 header fields that have been deprecated in NIFTI-1/2 formats remains
deprecated in JNIfTI files. These subfields include 

* `data_type` -> `A75DataTypeName`
* `db_name` -> `A75DBName`
* `extents` -> `A75Extends`
* `session_error` -> `A75SessionError`
* `regular` -> `A75Regular`
* `glmax` -> `A75GlobalMax`
* `glmin` -> `A75GlobalMin`

The use of these subfields are strictly for compatibility purposes and we highly 
recommended not to include them in JNIfTI files.

### NIFTIData

The primary data carried within a NIFTI-1/2 file is a numerical array of dimensions and types
specified by the `dim` and `datatype` records in the NIFTI-1 header, respectively. In 
JNIfTI, we use the `"NIFTIData"` record to store such information. It can 
additionally be expanded upon to store supplemental auxiliary data or metadata.

The NIFTIData record can be either an array object or a structure.

#### Array form

If stored as an array, the NIFTIData shall contain the same data as the NIFTI-1/2 primary 
data serialized using the JData specification. 

For example, a 3-D array of dimension Nx-by-Ny-by-Nz (`v_ijk` where `i=1,2,...,Nx`, 
`j=1,2,...,Ny`, `k=1,2,...,Nz`) can be stored in the direct array format as

```   
 "NIFTIData": [
   [ [v_111,v_112,v_113,...,v_11Nz], [v_121,v_122,v_123,...,v_12Nz],...,[v_1Ny1,v_1Ny2,v_1Ny3,...,v_1NyNz] ], 
   [ [v_211,v_212,v_113,...,v_21Nz], [v_221,v_222,v_223,...,v_22Nz],...,[v_2Ny1,v_2Ny2,v_2Ny3,...,v_2NyNz] ], 
   ...
   [ [v_Nx11,v_Nx12,v_Nx13,...,v_Nx1Nz],[v_Nx21,v_Nx22,v_Nx23,...,v_Nx2Nz],...,[v_NxNy1,v_NxNy2,...,v_NxNyNz] ]
 ]
```
or as the "annotated array format" as
```   
 "NIFTIData": {
       "_ArrayType_": "datatype",
       "_ArraySize_": [Nx,Ny,Nz],
       "_ArrayData_": [v_111,v_112,...,v_11Nz,v_121,v_122,...,v_NxNyNz]
 }
```
One can also apply data compression to reduce file sizes. In this case
```
 "NIFTIData": {
       "_ArrayType_": "datatype",
       "_ArraySize_": [Nx,Ny,Nz],
       "_ArrayZipType_": "zlib",
       "_ArrayZipSize_": [Nx,Ny,Nz],
       "_ArrayZipData_": "<base64-encoded zlib-compressed byte stream>"
 }
```

Please note that all composite data types (marked by "\*" in Table 2)
can not be stored in the direct form and therefore must be stored using
the annotated array format.

NIfTI-1/2 stores raw data values in the column-major element order (meaning
that the left-most index (`dim[1]`) is the fastest index while the right-most index
is the slowest) while JData `_ArrayData_` construct by default stores data elements
in the row-major order (i.e. the right-most index is the fastest index). As a result,
if one has to directly copy the NIfTI data buffer to the `_ArrayData_` element,
one must add `"_ArrayOrder_" : "c"` or `"_ArrayOrder_" : "col"` before `_ArrayData_`
or `_ArrayZipData_` entries in the above annotated `NIFTIData` forms.
Alternatively, if `_ArrayOrder_` is not specified (which suggests "row-major" order),
one must perform an N-D transpose operation to the NIfTI image data buffer before
serializing those to `_ArrayData_`.

All three of the above forms are valid JSON formats, and thus can be converted to the corresponding
BJData formats when a binary JNIfTI file is desired. Using the optimized N-D array 
header defined in the JData specification, the binary storage of the direct-form 
array can be efficiently written as

```   
[U][10][NIFTIData] [[] [$][datatype][#] [[] [$][l][#][U][3][Nx][Ny][Nz] [v_111,v_112,...,v_121,v_122,...,v_NxNyNz]
|----------------| |--------------------------------------------------| |----------------------------------------|
      name          optimized array container header for N-D array       row-major-order serialized N-D array data
```

Data compression can also be applied to the binary JNIfTI `NIFTIData` by 
converting the above corresponding annotated array into BJData form.
For example, for a `uint8` formatted 256x256x256 3D volume, one can use
```
[U][10][NIFTIData]
[[]
    [U][11][_ArrayType_][S][U][5][uint8]
    [U][11][_ArraySize_]
    [[]
       [U][256][U][256][U][256]
    []]
    [U][14][_ArrayZipType_][S][U][4][zlib]
    [U][14][_ArrayZipSize_]
    [[]
       [U][256][U][256][U][256]
    []]
    [U][14][_ArrayZipData_][H][L][lengh][... zlib-compressed byte stream ...]
[]]
```

#### Structure form

Using the structure form of `NIFTIData` allows for the storage of additional 
imaging-data-related metadata or auxiliary data, if desired. The structure shall have
the below format

```
 "NIFTIData": {
      "_DataInfo_":{
          ...
      },
      "Data":[
          ...
      ],
      "Properties": {
          ...
      },
      <...>
 }
```
The three subfields are
* **`Data`** : this is the only required subfield and its value must be the same 
  as the array data format described in the above subsection;
* **`Properties`**: this optional subfield can store additional auxiliary data
  using either an array or structure;
* **`_DataInfo_`**: this optional subfield is the JData-compatible metadata
  record which, if present, must be located as the 1st element of `NIFTIData`.

The `NIFTIData` structure can accommodate additional user-defined subfields which 
will be treated as auxiliary data.

#### Composite data types

From Table 2, six of the data types are composite data types and must be stored using
the annotated array format (for both text and binary forms). 

Note that `double128` and `complex256` are stored by first type-casting to `uint8` 
buffers of the same length. The parsing of these data structures is application 
dependent.

##### complex64
```
 "NIFTIData": {
       "_ArrayType_": "single",
       "_ArraySize_": [Nx,Ny,Nz],
       "_ArrayIsComplex_": true,
       "_ArrayData_": [
         [Nx*Ny*Nz singles for the real part],
         [Nx*Ny*Nz singles for the imaginary part]
       ]
 }
```

##### complex128
```
 "NIFTIData": {
       "_ArrayType_": "double",
       "_ArraySize_": [Nx,Ny,Nz],
       "_ArrayIsComplex_": true,
       "_ArrayData_": [
         [Nx*Ny*Nz doubles for the real part],
         [Nx*Ny*Nz doubles for the imaginary part]
       ]
 }
```
 
##### rgb24
```
 "NIFTIData": {
       "_ArrayType_": "uint8",
       "_ArraySize_": [Nx,Ny,Nz,3],
       "_ArrayData_": [ Nx*Ny*Nz*3 integers ]
 }
```
 
##### rgba32
```
 "NIFTIData": {
       "_ArrayType_": "uint8",
       "_ArraySize_": [Nx,Ny,Nz,4],
       "_ArrayData_": [ Nx*Ny*Nz*4 integers ]
 }
```
 
##### double128
```
 "NIFTIData": {
       "_ArrayType_": "uint8",
       "_ArraySize_": [Nx,Ny,Nz,16],
       "_ArrayData_": [ Nx*Ny*Nz*16 uint8 numbers ]
 }
```
 
##### complex256
```
 "NIFTIData": {
       "_ArrayType_": "uint8",
       "_ArraySize_": [Nx,Ny,Nz,32],
       "_ArrayData_": [ Nx*Ny*Nz*32 uint8 numbers ]
 }
```
 
### NIFTIExtension

In the NIFTI-1/2 format, if `extensions[0]` in the `nifti1_extender` structure is 
non-zero, NIFTI-1 stores one or multiple raw data buffers as the extension data.
If these extension data buffers are present, one may use the `NIFTIExtension` 
container to store these data buffers for compatibility purposes only. 

The `NIFTIExtension` must be an array object, with each element containing a
NIFTI-1 extension buffer in the order it is presented. 

```
 "NIFTIExtension":[
    {
        "Size": <i>,
        "Type": <i>|"s",
        "_ByteStream_":"base64-encoded byte stream for the 1st extension buffer"
    },
    {
        "Size": <i>,
        "Type": <i>|"s",
        "_ByteStream_":"base64-encoded byte stream for the 2nd extension buffer"
    },
    ...
 }
```
The `"Type"` field must be one of the 3 values according to the NIFTI-1 specification: 
* 0 or `""` - for unknown or private format
* 1 or `"dicom"` - for DICOM formatted data buffer
* 2 or `"afni"` - for AFNI group formatted data buffer

`"_ByteStream_"` is a JData keyword to store raw byte-stream buffers. For text-based JNIfTI/JData 
files, its value must be a base64-encoded string; no base64 encoding is needed when storing in the
binary format. For details, please see the JData specification ["Generic byte-stream data" section](https://github.com/NeuroJSON/jdata/blob/master/JData_specification.md#generic-byte-stream-data).

Again, because the extension data buffer has very little semantic information, the use of 
such a buffer is not recommended. Please consider converting the data to meaningful JData 
structures and storing it in the JNIfTI document as auxiliary data.


Data Organization and Grouping
------------------------

To facilitate the organization of multiple neuroimaging datasets, JNIfTI supports **optional**
data grouping mechanisms similar to those defined in the JData specification. 

In a JNIfTI document, one can use **"NIFTIGroup"** and **"NIFTIObject"** to organize
datasets in a hierarchical form. They are equivalent to the **`"_DataGroup_"`** and **`"_DataSet_"`**
constructs, respectively, as defined in the JData specification, but are specifically 
applicable to neuroimaging data. The format of `"NIFTIGroup"` and `"NIFTIObject"` are identical 
to the JData data grouping tags, i.e, they can be either an array or structure with an 
optional unique name (within the current document) via `"NIFTIGroup(unique name)"`
and `"NIFTIObject(unique name)"`

For example, the below JNIfTI snippet defines two data groups, each containing 
multiple NIFTI datasets.  Here we also show examples on how to store multiple `NIFTIHeader`
and `NIFTIData` records under a common parent, as well as on the use of `"_DataLink_"` as defined
in the JData specification for flexible data referencing.

```
{
    "NIFTIGroup(studyname1)": {
           "NIFTIObject(subj1)": {
               "NIFTIHeader":{ ... },
               "NIFTIData":[ ... ]
           },
           "NIFTIObject(subj2)": {
               "NIFTIHeader":{ ... },
               "NIFTIData":[ ... ]
           },
           "NIFTIObject(subj3)": {
               "NIFTIHeader(visit1)":{ ... },
               "NIFTIData(visit1)":[ ... ],
               "NIFTIHeader(visit2)":{ ... },
               "NIFTIData(visit2)":[ ... ]
           }
    },
    "NIFTIGroup(studyname2)": {
           "NIFTIObject(subj1)": {
               "NIFTIHeader":{ ... },
               "NIFTIData":[ ... ]
           },
           "NIFTIObject(subj2)": {
               "NIFTIData":[ ... ]
           },
           "NIFTIObject(subj3)": {
               "_DataLink_": "file:///space/test/jnifti/study2subj3.jnii"
           }
     }
}
```

Recommended File Specifiers
------------------------------

For the text-based JNIfTI file, the recommended file suffix is **`".jnii"`**; for 
the binary JNIfTI file, the recommended file suffix is **`".bnii"`**.

The MIME type for the text-based JNIfTI document is 
**`"application/jnifti-text"`**; that for the binary JNIfTI document is 
**`"application/jnifti-binary"`**


Summary
----------

In summary, this specification defines a pair of new file formats - the text and 
binary JNIfTI formats - to efficiently store and exchange neuroimaging scans, 
along with associated metadata and auxiliary measurements. Any previously 
generated NIFTI-1/2 file can be fully mapped to a JNIfTI document without 
losing any information. However, JNIfTI greatly expands upon the flexibility 
of the NIFTI-1/2 formats by removing a few key, inherent limitations, thereby 
allowing storage of multiple datasets, data compression, flexible data grouping, 
and user-defined metadata fields.

By using JSON-/BJData-compatible JData constructs, JNIfTI provides a highly 
portable, versatile, and extensible framework to store a large variety of 
neuroanatomical and functional imaging data. These constructs also confer 
user-readability in both text and binary formats through self-explanatory 
keywords. The widespread availability of JSON and BJData parsers provides 
the groundwork for easily sharing, processing, and processing JNIfTI data 
files without imposing an extensive programming overhead. The underlying 
JData specification offers greater flexibility in data organization and 
referencing mechanisms, which, in conjunction with a simple and highly 
readable human syntax, enables JNIfTI to record and share large-scale, 
complex neuroimaging datasets among researchers, clinicians, and data 
scientists alike.

