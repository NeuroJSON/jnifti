JNifTi: An extensible file format for storage and interchange of neuroimaging data
============================================================

- **Status of this document**: This document is current under development.
- **Copyright**: (C) Qianqian Fang (2019) <q.fang at neu.edu>
- **License**: Apache License, Version 2.0
- **Version**: 0.4
- **Abstract**:

> JNifTi is an extensible format for storage, interchange and processing
of neuroimaging data. It is capable of storing all NIFTI-1 and NIFTI-2 
formatted neuroimaging data, in the meantime, allows easy extensions and 
storage of non-array-based complex data structures and rich metadata using a 
simple syntax. Built upon the JData specification, a JNifTi file has both a 
text-based interface using the JavaScript Object Notation (JSON) [RFC4627] format 
and a binary interface using the Universal Binary JSON (UBJSON) serialization format.
A JNifTi file can be directly parsed by most existing JSON and UBJSON 
parsers. Advanced features include optional hierarchical data storage, image data 
grouping, data compression, streaming and encryption as permitted by JData data 
serialization framework.


## Table of Content

- [Introduction](#introduction)
  * [Background](#background)
  * [JNifTi specification overview](#jnifti-specification-overview)
- [Grammar](#grammar)
- [JNifTi Keywords](#jnifti-keywords)
  * [NIFTIHeader](#niftiheader)
    + [DataType (NIFTI-1 header: datatype)](#datatype-nifti-1-header-datatype)
    + [DimInfo (NIFTI-1 header: dim_info)](#diminfo-nifti-1-header-dim_info)
    + [Unit (NIFTI-1 header: xyzt_units)](#unit-nifti-1-header-xyzt_units)
    + [NIIFormat (NIFTI-1 header: magic)](#niiformat-nifti-1-header-magic)
    + [NIIHeaderSize (NIFTI-1 header: sizeof_hdr)](#niiheadersize-nifti-1-header-sizeof_hdr)
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
- [Data Orgnization and Grouping](#data-orgnization-and-grouping)
- [Recommended File Specifiers](#recommended-file-specifiers)
- [Summary](#summary)


Introduction
------------

### Background


NIFTI is a widely supported binary data format for storage of spatiotemporal
neruroimaging data. It provides an easy-to-use container for serializing
array-formatted imaging data and time series obtained from 
neuroanatomical or functional scans. The original NIFTI format (NIFTI-1) 
was derived from another widely supported medical image format, Analyze 7.5, 
and extended a 256-byte binary metadata header to a 352-byte binary header
(containing a 348-byte header for the metadata storage and another 4 bytes
as extension flags). In 2011, an upgraded NIFTI format - NIFTI-2 - permits
the storage of large sized imaging data by using 64-bit integers to storage
the image dimension data, which was previously stored in 16-bit integers.

The NIFTI-1/2 header specifies the data array dimensions, types, orientations,
and essential image acquisition settings such as slice thicknesses, 
maximum and minimum intensity values etc. The NIFTI header is followed 
by the primary data storage section, which contains the array numerical
values serialized in the row-major order (i.e. the fastest index of the 
array is the right-most index, similar to those in C/C++/Javascript and 
Python).

Although the NIFTI format is quite simple and easy to parse and store,
the fixed header size, rigid and static list of metadata fields, as well
as the limitation of storing only array-valued neuroimaging data make
it difficult to be extended to store of additional metadata records
or complex auxiliary data, such as physiological monitoring data or 
multi-modality data. The extensions from Analyze 7.5 format to NIFTI-1
and then NIFTI-2 formats rendered the new format incompatible with
the old data and supporting software. In addition, NIFTI formats 
has only a binary interface, and are not directly human-readable.

Over the past few years, JavaScript Object Notation (JSON) has become 
widely accepted among the Internet community due to its capability of storing 
complex data, excellent portability and human-readability. The proposals
and wide adoptions of binary JSON-like format, such as UBJSON and
MessagePack, also add complementary features such as support for typed 
data, smaller file sizes and faster processing speed. The JData specification
provides the foundation for serializing complex hierarchical data using
JSON/UBJSON constructs. This permits us to define language- and library-neutral
neuroimaging data representations using the simple and extensible constructs 
from JSON and UBJSON syntax.


### JNifTi specification overview

JNifTi is an extensible framework to store neuroimaging data and time series
using the JData representations, with a syntax compatible to the widely 
used JSON and UBJSON file formats. JNifTi specifically addresses the current 
limitations of the NIFTI formats, permitting flexible and rich metadata
support, fast and efficient storage of typed numerical array data, as well
as capabilities of recording additional array or non-array formed auxiliary
or multi-modality data entries, flexible grouping and internal data compression.

The purpose of this document is to

- define a 1-to-1 mapping between the existing NIFTI-1 and NIFTI-2 headers 
  to a JSON/UBJSON-based flexible metadata header structure, so that all NIFTI
  formatted metadata can be losslessly stored using JNifTi
- define data containers to losslessly convert and storage all NIFTI formatted
  neuroimaging data array, and show examples to use JData-enabled features for
  reducing file sizes, enhancing readability and organization
- demonstrate a set of flexible mechanisms to extend the capability of the 
  format to accommodate additional physiological, anatomical and multi-modal data

In the following sections, we will clarify the basic JNifTi grammar and define 
JNifTi header and data containers. The additional features and extension 
mechanisms are also discussed and exemplified.
 


Grammar
------------------------

All JNifTi files are JData specification compliant. The same as JData, it has
both a text format based on JSON serialization and a binary format based on 
the UBJSON serialization scheme. The two forms can be converted from one
to another.

Briefly, the text-based JNifTi is a valid JSON file with the extension to 
support concatenated JSON objects; the binary-format JNifTi is a valid UBJSON 
file with the extended syntax to support N-D array. Please refer to the JData 
specification for the definitions.

Each NIFTI-1/2 files carries a numerical N-dimensional (N-D, `N=1-7`) array as the 
primary data payload. According to the JData specification, N-D array has 
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
The direct storage format and the annotated storage format are equivalent. In the 
below sections, we use mostly the direct form to explain the data format, but
one shall also be able to store the data using the annotated format. We also note that
any valid JSON formatted data structure can be converted to a binary form using the
rules defined in the UBJSON specification (Draft 12).


JNifTi Keywords
------------------------

JNifTi uses three dedicated data containers to store NIFTI-1/2 compatible data:

* **`NIFTIHeader`**: a named structure to store all defined NIFTI-1/2 header
  metadata, and provides ability for user-defined additional metadata or headers,
* **`NIFTIData`**: an array or structure object to store the primary neuroimage 
  data. When using the array-form, it can support arbitrary number of dimensions
  and the length of each dimension can be stored as an integer up to 64bit.
* **`NIFTIExtention`**: (optional) an array of JData `"_ByteStream_"` objects to store the
  NIFTI-1 extension buffers (for compatibility purposes)
  
These three data containers can appear at any level in a JData tree. `NIFTIData` is the 
only required data object if a JNifTi file contains an neuroimaging dataset. 
When a `NIFTIHeader` field is stored under the same parent node as a `NIFTIData` object, 
the `NIFTIHeader` record serves as the metadata for the `NIFTIData` object. 
The optional `NIFTIExtension` is strictly used for compatibility purpose only, 
and is grouped with the `NIFTIHeader` and `NIFTIData` records if appear under the same node.

When multiple `NIFTIHeader`/`NIFTIData`/`NIFTIExtension` objects need to be stored under
the same parent node in a JData tree, they must be differentiated by attaching a 
name, as `NIFTIHeader(name)`, `NIFTIData(name)` and `NIFTIExtension(name)`. Objects
of the same name shall be grouped together and processed. Any of the JNifTi keyword
shall not be repeated more than once (with the same name or without a name) under the same
parent node as it is an invalid JSON construct.

### NIFTIHeader

The JNifTi format use a structure named `"NIFTIHeader"` to store NIFTI-compatible
header information.

In the below table, we define a 1-to-1 mapping from NIFTI-1/2 headers to the
corresponding JNifTi `NIFTIHeader` self-explanatory subfields

***Table 1. A mapping table for NIFTI-1 header and JNifTi NIFTIHeader structure***

|              NIFTI-1 Header                           |   JNifTi NIFTIHeader container        |
|-------------------------------------------------------|---------------------------------------|
|`struct nifti_1_header { ` **NIFTI-1 usage**           |`"NIFTIHeader": {                     `|
|                    **- was header_key substruct ---** |                                       |
|` int   sizeof_hdr;    `  **MUST be 348**              |`    "NIIHeaderSize": <i>,            `|
|` char  data_type[10]; `  **++UNUSED++**               |`    "DataTypeName":   "s",           `|
|` char  db_name[18];   `  **++UNUSED++**               |`    "A75DBName": "s",                `|
|` int   extents;       `  **++UNUSED++**               |`    "A75Extends": <i>,               `|
|` short session_error; `  **++UNUSED++**               |`    "A75SessionError": <i>,          `|
|` char  regular;       `  **++UNUSED++**               |`    "A75Regular": <i>,               `|
|` char  dim_info;      `  **MRI slice ordering**       |`    "DimInfo" : {                    `|
|                                                       |`          "Freq": <i>,               `|
|                                                       |`          "Phase": <i>,              `|
|                                                       |`          "Slice": <i>               `|
|               **- was image_dimension substruct ---** |`     },                              `|
|` short dim[8];        `  **Data array dimensions**    |`    "Dim": [dim[1],dim[2],dim[3],...],`|
|` float intent_p1 ;    `  **1st intent parameter**     |`    "Param1": <f>,                   `|
|` float intent_p2 ;    `  **2nd intent parameter**     |`    "Param2": <f>,                   `|
|` float intent_p3 ;    `  **3rd intent parameter**     |`    "Param3": <f>,                   `|
|` short intent_code ;  `  **NIFTI_INTENT_* code**      |`    "IntentCode": <i>,               `|
|` short datatype;      `  **Defines data type**        |`    "DataType": <i>\|"s",            `|
|` short bitpix;        `  **Number bits/voxel**        |`    "BitDepth": <i>,                 `|
|` short slice_start;   `  **First slice index**        |`    "FirstSliceID": <i>,             `|
|` float pixdim[8];     `  **Grid spacings**            |`    "VoxelSize": [<f>,<f>,<f>,...],  `|
|` float vox_offset;    `  **Offset into .nii file**    |`    "NIIByteOffset": <f>,            `|
|` float scl_slope ;    `  **Data scaling: slope**      |`    "ScaleSlope": <f>,               `|
|` float scl_inter ;    `  **Data scaling: offset**     |`    "ScaleOffset": <f>,              `|
|` short slice_end;     `  **Last slice index**         |`    "LastSliceID": <i>,              `|
|` char  slice_code ;   `  **Slice timing order**       |`    "SliceCode": <i>,                `|
|` char  xyzt_units ;   `  **Units of pixdim[1..4]**    |`    "Unit":{"L":<i>\|"s","T":<i>\|"s"},`|
|` float cal_max;       `  **Max display intensity**    |`    "MaxIntensity": <f>,             `|
|` float cal_min;       `  **Min display intensity**    |`    "MinIntensity": <f>,             `|
|` float slice_duration;`  **Time for 1 slice**         |`    "SliceTime": <f>,                `|
|` float toffset;       `  **Time axis shift**          |`    "TimeOffset": <f>,               `|
|` int   glmax;         `  **++UNUSED++**               |`    "A75GLMax": <i>,                 `|
|` int   glmin;         `  **++UNUSED++**               |`    "A75GLMin": <i>,                 `|
|                  **- was data_history substruct ---** |                                       |
|` char  descrip[80];   `  **any text you like**        |`    "Description": "s",              `|
|` char  aux_file[24];  `  **auxiliary filename**       |`    "AuxFile": "s",                  `|
|                                                       |                                       |
|` short qform_code ;   `  **NIFTI_XFORM_\* code**       |`    "QForm": <i>,                    `|
|` short sform_code ;   `  **NIFTI_XFORM_\* code**       |`    "SForm": <i>,                    `|
|                                                       |                                       |
|` float quatern_b ;    `  **Quaternion b param**       |`    "QuaternB": <f>,                 `|
|` float quatern_c ;    `  **Quaternion c param**       |`    "QuaternC": <f>,                 `|
|` float quatern_d ;    `  **Quaternion d param**       |`    "QuaternD": <f>,                 `|
|` float qoffset_x ;    `  **Quaternion x shift**       |`    "QuaternXOffset": <f>,           `|
|` float qoffset_y ;    `  **Quaternion y shift**       |`    "QuaternYOffset": <f>,           `|
|` float qoffset_z ;    `  **Quaternion z shift**       |`    "QuaternBOffset": <f>,           `|
|                                                       |                                       |
|` float srow_x[4] ;    `  **1st row affine transform** |`    "Affine": [ [<f>,<f>,<f>,<f>],   `|
|` float srow_y[4] ;    `  **2nd row affine transform** |`        [<f>,<f>,<f>,<f>],           `|
|` float srow_z[4] ;    `  **3rd row affine transform** |`        [<f>,<f>,<f>,<f>]            `|
|                                                       |`    ],                               `|
|` char intent_name[16];`  **'name' or meaning of data**|`    "Name" : "s",                    `|
|` char magic[4] ;     `  **MUST be "ni1\0" or "n+1\0"**|`    "NIIFormat": "s",                `|
|`} ;                   `  **348 bytes total**          |`                                     `|
|`struct nifti1_extender { char extension[4] ; } ;     `|`    "Extender": [<i>,<i>,<i>,<i>],   `|
|                                                       |`    <...>                            `|
|                                                       |`}                                    `|

In the above table, the notations are explained below

* `<i>` represents an integer value (signed integer of 8, 16, 32 or 64bit)
* `<f>` represents an numerical value (including integers, 32bit and 64bit floating point numbers)
* `"s"` represents a UTF-8 encoded string of arbitrary length
* `[...]` represents a vector of variable length
* `<...>` represents (optional) additional subfields for user-defined header or future extensions
* `<i>|"s"` represents alternative forms, in this example, the field can be either an integer or a string


To convert an NIFTI-1/2 header to the JNifTi `NIFTIHeader` structure, the storage type in the
`NIFTIHeader` subfields must have equal or larger byte length to store the original NIFTI header 
data without losing accuracy; in the case of a string value, the new string must have the same 
length or longer to store the entire original string value.

If the NIFTI header field contains an array, the converted `NIFTIHeader` subfield shall also
contain an array object sorted in the same order.

Not all `"NIFTIHeader"` subfields shall present. However, if any of the subfield in 
the NIFTI-1/2 header carry meaningful data, the corresponding subfield in the `NIFTIHeader` 
must present. The order of the `NIFTIHeader` subfields is not required.

A reversed direction mapping, i.e. from JNifTi to NIFTI-1/2, is not guaranteed to be lossless.

#### DataType (NIFTI-1 header: datatype)

To enhance the readability of the header, we allow one to use a string instead of an integer
code to represent data type (i.e. the `DataType` subfield in `NIFTIHeader`). The below
table maps the NIFTI data type codes to the acceptable data type strings.

***Table 2. A mapping table from NIFTI-1 data types to string-valued JNifTi data types and 
storage types in UBJSON***

|          NIFTI-1/2 Data Types               | JNifTi DataType  |UBJSON Type|
|---------------------------------------------|------------------|-----------|
|**unsigned char**                            |                  |	     |
|`#define NIFTI_TYPE_UINT8              2    `|`  "uint8"       `| `U`       |
|**signed short**                             |                  |	     |
|`#define NIFTI_TYPE_INT16              4    `|`  "int16"       `| `I`       |
|**signed int**                               |                  |	     |
|`#define NIFTI_TYPE_INT32              8    `|`  "int32"       `| `l`       |
|**32 bit float**                             |                  |	     |
|`#define NIFTI_TYPE_FLOAT32           16    `|`  "single"      `| `d`       |
|**64 bit complex = 2 32 bit floats**         |                  |	     |
|`#define NIFTI_TYPE_COMPLEX64         32    `|`  "complex64" `\*| `d` (x2)  |
|**64 bit float = double**                    |                  |	     |
|`#define NIFTI_TYPE_FLOAT64           64    `|`  "double"      `| `D`       |
|**3x 8 bit bytes**                           |                  |	     |
|`#define NIFTI_TYPE_RGB24            128    `|`  "rgb24"     `\*| `U` (x3)  |
|**signed char**                              |                  |	     |
|`#define NIFTI_TYPE_INT8             256    `|`  "int8"        `| `i`       |
|**unsigned short**                           |                  |	     |
|`#define NIFTI_TYPE_UINT16           512    `|`  "uint16"      `| `I`       |
|**unsigned int**                             |                  |	     |
|`#define NIFTI_TYPE_UINT32           768    `|`  "uint32"      `| `l`       |
|**signed long long**                         |                  |	     |
|`#define NIFTI_TYPE_INT64           1024    `|`  "int64"       `| `L`       |
|**unsigned long long**                       |                  |	     |
|`#define NIFTI_TYPE_UINT64          1280    `|`  "uint64"      `| `L`       |
|**128 bit float = long double**              |                  |	     |
|`#define NIFTI_TYPE_FLOAT128        1536    `|`  "double128" `\*| `U` (x16) |
|**2x 64 bit floats = 128 bit complex**       |                  |	     |
|`#define NIFTI_TYPE_COMPLEX128      1792    `|`  "complex128"`\*| `D` (x2)  |
|**2x 128 bit floats = 256 bit complex**      |                  |	     |
|`#define NIFTI_TYPE_COMPLEX256      2048    `|`  "complex256"`\*| `U` (x32) |
|**4x 8 bit bytes**                           |                  |	     |
|`#define NIFTI_TYPE_RGBA32          2304    `|`  "rgba32"    `\*| `U` (x4)  |

A "\*" sign in the JNifTi DataType column indicates that the data is a composite type, and must
be stored using the "annotated" JData format.

#### Dim (NIFTI-1 header: `dim`)

In the NIFTI-1/2 formats, `dim[0]` stores the number of dimensions of the data, and `dim[1]`
to `dim[7]` store the dimension data. In `NIFTIHeader`, we use an array object `Dim` to
store the effective dimensional data starting from `dim[1]` and the length of `Dim` array
should equal to `dim[0]`.

#### DimInfo (NIFTI-1 header: `dim_info`)

In the NIFTI-1/2 formats, the `dim_info` field combines 3 parameters, `freq_dim`, `phase_dim` 
and `slice_dim` using bit-masks. To enhance readability, in JNifTi, we use explicit subfields
to represent each of the parameter, `"Freq"`, `"Phase"` and `"Slice"` inside the "DimInfo" structure
to store the corresponding values. A fixed order of the 3 subfields is not required.

#### Unit (NIFTI-1 header: `xyzt_units`)

The NIFTI-1/2 `xyzt_units` is a combined mask of both space and time.
In JNifTi, we map it to a structure with at least two subfields:
`"L"` to store spatial unit, and `"T"` to store time unit. 

Similar to `DataType`, both `L` and `T` allow to use an integer value, matching
that of the NIFTI-1/2 unit definitions, or a more descriptive string value
to specify the units. The mapping between NIFTI-1/2 units to the string forms
is listed below

***Table 3. A mapping table for NIFTI-1 unit types and string-valued JNifTi `NIFTIHeader` Unit field***

|          NIFTI-1/2 Unit Types                | JNifTi Unit  |
|----------------------------------------------|--------------|
|`#define NIFTI_UNITS_UNKNOWN 0               `|  `"unknown"` |
|**Length Units**                              |              |                         
|*NIFTI code for meters*                       |	             |
|`#define NIFTI_UNITS_METER   1               `|  `"m"`       |
|*NIFTI code for millimeters*                  |	             |
|`#define NIFTI_UNITS_MM      2               `|  `"mm"`      |
|*NIFTI code for micrometers*                  |	             |
|`#define NIFTI_UNITS_MICRON  3               `|  `"um"`      |
|**Time Units**                                |              |                         
|*NIFTI code for seconds*                      |	             |
|`#define NIFTI_UNITS_SEC     8               `|  `"s"`       |
|*NIFTI code for milliseconds*                 |	             |
|`#define NIFTI_UNITS_MSEC   16               `|  `"ms"`      |
|*NIFTI code for microseconds*                 |	             |
|`#define NIFTI_UNITS_USEC   24               `|  `"us"`      |
|**Other Units**                               |              |                         
|*NIFTI code for Hertz*                        |	             |
|`#define NIFTI_UNITS_HZ     32               `|  `"hz"`      |
|*NIFTI code for ppm*                          |	             |
|`#define NIFTI_UNITS_PPM    40               `|  `"ppm"`     |
|*NIFTI code for radians per second*           |	             |
|`#define NIFTI_UNITS_RADS   48               `|  `"rad"`     |


#### NIIFormat (NIFTI-1 header: `magic`)

The `"NIIFormat"` field stores the original NIFTI-1 format identifier, and is designed for 
compatibility purposes only. The use of this field is depreciated.

#### NIIHeaderSize (NIFTI-1 header: `sizeof_hdr`)

The `"NIIHeaderSize"` field stores the original NIFTI-1 header size, and is designed for 
compatibility purposes only. The use of this field is depreciated.

#### NIIByteOffset (NIFTI-1 header: `vox_offset`)

The `"NIIByteOffset"` field stores the original NIFTI-1 voxel data starting position offset, 
and is designed for compatibility purposes only. The use of this field is depreciated.

#### Other depreciated subfields

All Analyze 7.5 header fields that have been depreciated in NIFTI-1/2 formats remains
depreciated in JNifTi files. These subfields include 

* `db_name` -> `A75DBName`
* `extents` -> `A75Extends`
* `session_error` -> `A75SessionError`
* `regular` -> `A75Regular`
* `glmax` -> `A75GLMax`
* `glmin` -> `A75GLMin`

The use of these subfields are strictly for compatibility purposes and are highly 
recommended not to include in JNifTi files.

### NIFTIData

The primary data carried in an NIFTI-1/2 file is a numerical array with dimensions and types
specified by the `dim` and `datatype` records, respectively, in the NIFTI-1 header. In 
JNifTi, we use the `"NIFTIData"` record to store such information, with the ability to 
expand to store additional auxiliary data or metadata.

The NIFTIData record can be either an array object or a structure.

#### Array form

If stored as an array, the NIFTIData shall contain the same data as the NIFTI-1/2 primary 
data, serialized using the JData specification. 

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
One can also apply data compression to reduce file size. In this case
```
 "NIFTIData": {
       "_ArrayType_": "datatype",
       "_ArraySize_": [Nx,Ny,Nz],
       "_ArrayCompressionMethod_": "zlib",
       "_ArrayCompressionSize_": [Nx,Ny,Nz],
       "_ArrayCompressedData_": "<base64-encoded zlib-compressed byte stream>"
 }
```

Please note that all composite data types (marked by "\*" in Table 2)
can not be stored in the direct form, and one must use the annotated array format
instead.

All above three forms are valid JSON formats, and thus can be converted to the corresponding 
UBJSON formats when a binary JNifTi file is desired. Using the optimized N-D array 
header defined in the JData specification, the binary storage of the direct-form 
array can be efficiently written as

```   
[U][10][NIFTIData] [[] [$][datatype][#] [[] [$][l][#][3][Nx][Ny][Nz] [v_111,v_112,...,v_121,v_122,...,v_NxNyNz]
|----------------| |-----------------------------------------------| |----------------------------------------|
      name          optimized array container header for N-D array    row-major-order serialized N-D array data
```

Data compression can also be applied to the binary JNifTi `NIFTIData` if
one convers the above corresponding annotated array form into UBJSON.
For example, for a `uint8` formatted 256x256x256 3D volume, one can write as
```
[U][10][NIFTIData]
[[]
    [U][11][_ArrayType_][S][U][5][uint8]
    [U][11][_ArraySize_]
    [[]
       [U][256][U][256][U][256]
    []]
    [U][24][_ArrayCompressionMethod_][S][U][4][zlib]
    [U][22][_ArrayCompressionSize_]
    [[]
       [U][256][U][256][U][256]
    []]
    [U][21][_ArrayCompressedData_][H][L][lengh][... zlib-compressed byte stream ...]
[]]
```

#### Structure form

If storage of additional image-data-related metadata or auxiliary data is desired,
one can choose to use a structure to store `NIFTIData`. The structure shall have
the below 

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
* **`Data`** : this is the only required subfield, and its value must be the same 
  as the array data format described in the above subsection;
* **`Properties`**: this optional subfield can storage additional auxiliary data
  using either an array or structure;
* **`_DataInfo_`**: this optional subfield is the JData-compatible metadata
  record, which, if present, must be located as the 1st element of `NIFTIData`.

The NIFTIData structure can accommodate additional user-defined subfields 
and those shall be treated as auxiliary data.

#### Composite data types

From Table 2, six of the data types are composite data types and must be stored using
the annotated array format (for both text and binary forms). 

Note that `double128` and `complex256` are stored by first type-casted to `uint8` 
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
       "_ArrayIsComplex_": true,
       "_ArrayData_": [ Nx*Ny*Nz*3 integers ]
 }
```
 
##### rgba32
```
 "NIFTIData": {
       "_ArrayType_": "uint8",
       "_ArraySize_": [Nx,Ny,Nz,4],
       "_ArrayIsComplex_": true,
       "_ArrayData_": [ Nx*Ny*Nz*4 integers ]
 }
```
 
##### double128
```
 "NIFTIData": {
       "_ArrayType_": "uint8",
       "_ArraySize_": [Nx,Ny,Nz,16],
       "_ArrayIsComplex_": true,
       "_ArrayData_": [ Nx*Ny*Nz*16 uint8 numbers ]
 }
```
 
##### complex256
```
 "NIFTIData": {
       "_ArrayType_": "uint8",
       "_ArraySize_": [Nx,Ny,Nz,32],
       "_ArrayIsComplex_": true,
       "_ArrayData_": [ Nx*Ny*Nz*32 uint8 numbers ]
 }
```
 
### NIFTIExtension

In the NIFTI-1/2 format, if `extensions[0]` in the `nifti1_extender` structure is 
set to non-zero, NIFTI-1 stores one or multiple raw data buffers as the extension data.
If these extension data buffer present, one may use the `NIFTIExtension` container
to store these data buffers for compatibility purposes only. 

The `NIFTIExtension` must be an array object, with each element containing a
NIFTI-1 extension buffer in the order of presence. 

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
* 0 or `"unknown"` - for unknown or private format
* 1 or `"dicom"` - for DICOM formatted data buffer
* 2 or `"afni"` - for AFNI group formatted data buffer

`"_ByteStream_"` is a JData keyword to store raw byte-stream buffers. For text-based JNifti/JData 
files, its value must be a base64-encoded string; no base64 encoding is needed when stored in the
binary format. For details, please see the JData specification "Generic byte-stream data" section.

Again, because the extension data buffer has very little semantic information, the use of 
such buffer is not recommended. Please consider converting the data to meaning JData structures
and store it to the JNifTi document as auxiliary data.


Data Orgnization and Grouping
------------------------

To facilitate the organization of multiple neuroimaging datasets, JNifTi supports optional 
data grouping mechanisms similar to those defined in the JData specification. 

In a JNifTi document, one can use **"NIFTIGroup"** and **"NIFTIObject"** to 
They are equivalent to the **`"_DataGroup_"`** and **`"_DataSet_"`**
constructs, respectively, as defined in the JData specification, but are specifically 
applicable to neuroimaging data. The format of "NIFTIGroup" and "NIFTIObject" are identical 
to JData data grouping tags, i.e, they can be either an array or structure, with an 
optional unique name (within the current document) via `"NIFTIGroup(unique name)"`
and `"NIFTIObject(unique name)"`

For example, the below JNifTi snippet defines two data groups with each containing 
multiple NIFTI datasets.  Here we also show examples on storing multiple `NIFTIHeader`
and `NIFTIData` records under a common parent, as well as the use of `"_DataLink_"` defined
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

For the text-based JNifTi file, the recommended file suffix is **`".jnii"`**; for 
the binary JNifTi file, the recommended file suffix is **`".bnii"`**.

The MIME type for the text-based JNifTi document is 
**`"application/jnifti-text"`**; that for the binary JNifTi document is 
**`"application/jnifti-binary"`**


Summary
----------

In summary, this specification defines a pair of new file formats - text and binary JNifTi 
formats - to efficiently store and exchange neuroimaging scans, the associated metadata 
and auxiliary measurements. Any previously generated NIFTI-1/2 file can be 100% mapped 
to a JNifTi document without losing any information. However, JNifTi greatly expands the 
flexibility of NIFTI-1/2 format and removed their inherent limitations, allowing the 
storage of multiple datasets, data compression, flexible data grouping and user-defined 
metadata fields.

By using JSON/UBJSON compatible JData constructs, JNifTi provides a highly portable, versatile
and extensible framework to store a large variety of neuroanatomical and functional
image data. Both formats are human-readable with self-explanatory keywords. The wide-spread 
availability of JSON and UBJSON parser, as well as the simple underlying syntax allows one
to easily share, parse and process these data files, without introducing extensive programming
overhead. The flexible data organization and referencing mechanisms offered by the underlying 
JData specification make it possible to record and share large scale complex neuroimaging 
datasets among researchers, clinicians and data scientists.
