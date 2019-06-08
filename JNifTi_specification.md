 JNifTi: An extensible file format for storage and interchange of neuroimaging data
============================================================

- **Status of this document**: This document is current under development.
- **Copyright**: (C) Qianqian Fang (2019) <q.fang at neu.edu>
- **License**: Apache License, Version 2.0
- **Version**: 0.4
- **Abstract**:

> JNifTi is an extensible format for storage, interchange and processing
of neuroimaging data. It is capable of storing all NifTi-1 and NifTi-2 
formatted neuroimaging data, in the meantime, allows easy extensions and 
storage of non-array based complex data structures and rich metadata using a 
simple syntax. Built upon the JData specification, a JNifTi file has both a 
text-based format using the JavaScript Object Notation (JSON) [RFC4627] format 
and a binary format using the Universal Binary JSON (UBJSON) serialization format.
A JNifTi file can be directly parsed by most existing JSON and UBJSON 
parsers. JNifTi also permits optional hierachical data storage, image data 
grouping, image data compression, streaming and encryption enabled by JData
data serialization format.


## Table of Content

- [Introduction](#introduction)
  * [Background](#background)
  * [JNifTi specification overview](#jnifti-specification-overview)
- [Grammar](#grammar)
- [JNifTi Keywords](#jnifti-keywords)
  * [NIFTI_Header](#nifti-header)
    + [DataType (NIFTI-1 header: datatype)](#datatype--nifti-1-header--datatype-)
    + [DimInfo (NIFTI-1 header: dim_info)](#diminfo--nifti-1-header--dim-info-)
    + [Unit  (NIFTI-1 header: xyzt_units)](#unit---nifti-1-header--xyzt-units-)
    + [NIIFormat (NIFTI-1 header: magic)](#niiformat--nifti-1-header--magic-)
    + [NIIHeaderSize (NIFTI-1 header: sizeof_hdr)](#niiheadersize--nifti-1-header--sizeof-hdr-)
    + [Other depreciated subfields](#other-depreciated-subfields)
  * [NIFTI_Data](#nifti-data)
- [Recommended File Specifiers](#recommended-file-specifiers)
- [Summary](#summary)


Introduction
------------

### Background


NIFTI is a widely supported data format for the storage of spatiotemporal
neruroimaging data. It provides an easy-to-use container for serializing
and storage of array-formatted image data and time series obtained from 
neuroanatomical or functional scans. The original NIFTI format (NIFTI-1) 
was derived from another widely supported medical image format, Analyze 7.5, 
and extended a 256-byte binary metadata header to a 352-byte binary header
(containing a 348-byte header for the metadata storage and another 4 bytes
as extension flags). In 2011, an upgraded NIFTI format - NIFTI-2 - permits
the storage of large sized imaging data by using 64-bit integers to storage
the image dimension data, which was previously storaged in 16-bit integers.

The NIFTI header specifies the data array dimension, types, orientations,
and essential image acquisition settings such as slice thicknesses, 
maximum and minimum intensity values etc. The NIFTI header is followed 
by the primary data storage section, which contains the array numerical
values serialized in the row-major order (i.e. the fastest index of the 
array is the right-most index, similar to those in C/C++/Javascript and 
Python).

Although the NIFTI format is quite simple and easy to parse and store,
the fixed header size, rigid and static list of metadata fields, as well
as the limitation of storing only array-valued neuroimaging data make
it difficult to be extended to storage of additional metadata records
or complex auxilliary data, such as physiological monitoring data or 
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
as capabilities of recording additional array or non-array formed auxillary
or multi-modality data entries, flexible grouping and internal data compression.

The purpose of this document is to

- define a 1-to-1 mapping between the existing NIFTI-1 and NIFTI-2 headers 
  to a JSON/UBJSON-based flexible metadata header structure, so that all NIFTI
  formatted data can be losslessly storaged using JNifTi
- define data containers to losslessly convert and storage all NIFTI formatted
  neuroimaging scan data, and show examples to use JData-enabled features for
  reducing file sizes and enhancing readability and organization
- demonstrate a set of flexible mechanisms to extend the capability of the 
  format to accommodate additional physiological, anatomical and multi-modal data

In the following sections, we will clarify the basic JNifTi grammar and define 
JNifTi header and data containers. The additional features and extension 
mechanisms are also discussed and examplified.
 


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

All NIFTI-1/2 files carry a numerical N-dimensional (N-D, N=1-7) array as the 
primary data payload. According to the JData specification, N-D array has 
two equivallent and interchangable storage forms - the direct storage format 
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
The direct storage format and the annotated storage format are equivallent. In the 
below sections, we use mostly the direct form to explain the data format, but
one shall also be able to store the data using the annotated format.


JNifTi Keywords
------------------------

JNifTi uses two dedicated data containers to storge NIFTI-1/2 compatible data:

* **`NIFTI_Header`**: a named structure to storge all defined NIFTI-1/2 header
  metadata, and provides ability for user-defined additional metadata or headers, and
* **`NIFTI_Data`**: an array or structure object to store the primary neuroimage 
  data. When using the array-form, it can support arbitrary number of dimensions
  and the length of each dimension can be stored as an integer up to 64bit.

All JNifTi keywords are case sensitive.


### NIFTI_Header

The JNifTi format use a structure named `"NIFTI_Header"` to store NIFTI-compatible
header information.

In the below table, we define a 1-to-1 mapping from NIFTI-1/2 headers to the
corresponding JNifTi `NIFTI_Header` self-explanatory subfields

|              NIFTI-1 Header                           |  JNifTi NIFTI_Header container        |
|-------------------------------------------------------|---------------------------------------|
|`struct nifti_1_header { /* NIFTI-1 usage         */  `|`"NIFTI_Header": {                    `|
|`                 /*--- was header_key substruct ---*/`|                                       |
|` int   sizeof_hdr;    /*!< MUST be 348           */  `|`    "NIIHeaderSize": <i>,            `|
|` char  data_type[10]; /*!< ++UNUSED++            */  `|`    "DataTypeName":   "s",           `|
|` char  db_name[18];   /*!< ++UNUSED++            */  `|`    "A75DBName": <i>,                `|
|` int   extents;       /*!< ++UNUSED++            */  `|`    "A75Extends": <i>,               `|
|` short session_error; /*!< ++UNUSED++            */  `|`    "A75SessionError": <i>,          `|
|` char  regular;       /*!< ++UNUSED++            */  `|`    "A75Regular": <i>,               `|
|` char  dim_info;      /*!< MRI slice ordering.   */  `|`    "DimInfo" : {                    `|
|                                                       |`          "Freq": <i>,               `|
|                                                       |`          "Phase": <i>,              `|
|                                                       |`          "Slice": <i>               `|
|`            /*--- was image_dimension substruct ---*/`|`     },                              `|
|` short dim[8];        /*!< Data array dimensions.*/  `|`    "Dim": [<i>,<i>,<i>,...],        `|
|` float intent_p1 ;    /*!< 1st intent parameter. */  `|`    "Param1": <f>,                   `|
|` float intent_p2 ;    /*!< 2nd intent parameter. */  `|`    "Param2": <f>,                   `|
|` float intent_p3 ;    /*!< 3rd intent parameter. */  `|`    "Param3": <f>,                   `|
|` short intent_code ;  /*!< NIFTI_INTENT_* code.  */  `|`    "IntentCode": <i>,               `|
|` short datatype;      /*!< Defines data type!    */  `|`    "DataType": <i>\|"s",            `|
|` short bitpix;        /*!< Number bits/voxel.    */  `|`    "BitDepth": <i>,                 `|
|` short slice_start;   /*!< First slice index.    */  `|`    "FirstSliceID": <i>,             `|
|` float pixdim[8];     /*!< Grid spacings.        */  `|`    "VoxelSize": [<f>,<f>,<f>,...],  `|
|` float vox_offset;    /*!< Offset into .nii file */  `|`    "ByteOffset": <f>,               `|
|` float scl_slope ;    /*!< Data scaling: slope.  */  `|`    "ScaleSlope": <f>,               `|
|` float scl_inter ;    /*!< Data scaling: offset. */  `|`    "ScaleOffset": <f>,              `|
|` short slice_end;     /*!< Last slice index.     */  `|`    "LastSliceID": <i>,              `|
|` char  slice_code ;   /*!< Slice timing order.   */  `|`    "SliceCode": <i>,                `|
|` char  xyzt_units ;   /*!< Units of pixdim[1..4] */  `|`    "Unit":{"L":<i>\|"s","T":<i>\|"s"},`|
|` float cal_max;       /*!< Max display intensity */  `|`    "MaxIntensity": <f>,             `|
|` float cal_min;       /*!< Min display intensity */  `|`    "MinIntensity": <f>,             `|
|` float slice_duration;/*!< Time for 1 slice.     */  `|`    "SliceTime": <f>,                `|
|` float toffset;       /*!< Time axis shift.      */  `|`    "TimeOffset": <f>,               `|
|` int   glmax;         /*!< ++UNUSED++            */  `|`    "A75GLMax": <i>,                 `|
|` int   glmin;         /*!< ++UNUSED++            */  `|`    "A75GLMin": <i>,                 `|
|`               /*--- was data_history substruct ---*/`|                                       |
|` char  descrip[80];   /*!< any text you like.    */  `|`    "Description": "s",              `|
|` char  aux_file[24];  /*!< auxiliary filename.   */  `|`    "AuxFile": "s",                  `|
|                                                       |                                       |
|` short qform_code ;   /*!< NIFTI_XFORM_* code.   */  `|`    "QForm": <i>,                    `|
|` short sform_code ;   /*!< NIFTI_XFORM_* code.   */  `|`    "SForm": <i>,                    `|
|                                                       |                                       |
|` float quatern_b ;    /*!< Quaternion b param.   */  `|`    "QuaternB": <f>,                 `|
|` float quatern_c ;    /*!< Quaternion c param.   */  `|`    "QuaternC": <f>,                 `|
|` float quatern_d ;    /*!< Quaternion d param.   */  `|`    "QuaternD": <f>,                 `|
|` float qoffset_x ;    /*!< Quaternion x shift.   */  `|`    "QuaternXOffset": <f>,           `|
|` float qoffset_y ;    /*!< Quaternion y shift.   */  `|`    "QuaternYOffset": <f>,           `|
|` float qoffset_z ;    /*!< Quaternion z shift.   */  `|`    "QuaternBOffset": <f>,           `|
|                                                       |                                       |
|` float srow_x[4] ;    /*!< 1st row affine transform. `|`    "Affine": [ [<f>,<f>,<f>,<f>],   `|
|` float srow_y[4] ;    /*!< 2nd row affine transform. `|`        [<f>,<f>,<f>,<f>],           `|
|` float srow_z[4] ;    /*!< 3rd row affine transform. `|`        [<f>,<f>,<f>,<f>]            `|
|                                                       |`    ],                               `|
|` char intent_name[16];/*!< 'name' or meaning of data.`|`    "Name" : "s",                    `|
|` char magic[4] ;      /*!< MUST be "ni1\0" or "n+1\0"`|`    "NIIFormat": "s",                `|
|`} ;                   /**** 348 bytes total ****/    `|`                                     `|
|`struct nifti1_extender { char extension[4] ; } ;     `|`    "Extender": [<i>,<i>,<i>,<i>],   `|
|`                                                     `|`    <...>                            `|
|`                                                     `|`}                                    `|

In the above table, the notations are explained below

* `<i>` represents an integer value (signed integer of 8, 16, 32 or 64bit)
* `<f>` represents an numerical value (including integers, 32bit and 64bit floating point numbers)
* `"s"` represents a UTF-8 encoded string of arbitrary length
* `[...]` represents a vector of variable length
* `<...>` represents (optional) additional JData subfields for user-defined header or future extensions
* `<i>|"s"` represents alternative forms, in this example, the field can be either an integer or a string


To convert an NIFTI-1/2 header to the JNifTi `NIFTI_Header` structure, the storage type in the
`NIFTI_Header` subfields must have equal or larger byte length to store the original NIFTI header 
data without lossing accuracy; in the case of a string value, the new string must have the same 
length or longer to store the entire original string value.

If the NIFTI header field contains an array, the converted `NIFTI_Header` subfield shall also
contain an array object sorted in the same order.

Not all "NIFTI_Header" subfields shall present. However, if any of the subfield in 
the NIFTI-1/2 header carry meaningful data, the corresponding subfield in the `NIFTI_Header` 
must present. The order of the `NIFTI_Header` subfields is not required.

A reversed direction mapping, i.e. from JNifTi to NIFTI-1/2, is not guaranteed to be lossless.

#### DataType (NIFTI-1 header: datatype)

To enhance the readability of the header, we allow one to use a string instead of an integer
code to represent data type (i.e. the `DataType` subfield in `NIFTI_Header`). The below
table maps the NIFTI data type codes to the acceptable data type strings.

|          NIFTI-1/2 Data Types               | JNifTi DataType  |
|---------------------------------------------|------------------|
|`/*! unsigned char. */                      `|`                `|
|`#define NIFTI_TYPE_UINT8             2     `|`  "uint8"       `|
|`/*! signed short. */                       `|`                `|
|`#define NIFTI_TYPE_INT16             4     `|`  "int16"       `|
|`/*! signed int. */                         `|`                `|
|`#define NIFTI_TYPE_INT32             8     `|`  "int32"       `|
|`/*! 32 bit float. */                       `|`                `|
|`#define NIFTI_TYPE_FLOAT32            16   `|`  "single"      `|
|`/*! 64 bit complex = 2 32 bit floats. */   `|`                `|
|`#define NIFTI_TYPE_COMPLEX64      32       `|`  "complex64"   `|
|`/*! 64 bit float = double. */              `|`                `|
|`#define NIFTI_TYPE_FLOAT64            64   `|`  "double"      `|
|`/*! 3 8 bit bytes. */                      `|`                `|
|`#define NIFTI_TYPE_RGB24           128     `|`  "rgb24"       `|
|`/*! signed char. */                        `|`                `|
|`#define NIFTI_TYPE_INT8           256      `|`  "int8"        `|
|`/*! unsigned short. */                     `|`                `|
|`#define NIFTI_TYPE_UINT16           512    `|`  "uint16"      `|
|`/*! unsigned int. */                       `|`                `|
|`#define NIFTI_TYPE_UINT32           768    `|`  "uint32"      `|
|`/*! signed long long. */                   `|`                `|
|`#define NIFTI_TYPE_INT64          1024     `|`  "int64"       `|
|`/*! unsigned long long. */                 `|`                `|
|`#define NIFTI_TYPE_UINT64          1280    `|`  "uint64"      `|
|`/*! 128 bit float = long double. */        `|`                `|
|`#define NIFTI_TYPE_FLOAT128          1536  `|`  "double128"   `|
|`/*! 128 bit complex = 2 64 bit floats. */  `|`                `|
|`#define NIFTI_TYPE_COMPLEX128   1792       `|`  "complex128"  `|
|`/*! 256 bit complex = 2 128 bit floats */  `|`                `|
|`#define NIFTI_TYPE_COMPLEX256   2048       `|`  "complex256"  `|
|`/*! 4 8 bit bytes. */                      `|`                `|
|`#define NIFTI_TYPE_RGBA32          2304    `|`  "rgba32"      `|


#### DimInfo (NIFTI-1 header: dim_info)

In the NIFTI-1/2 formats, the `dim_info` field combines 3 parameters, `freq_dim`, `phase_dim` 
and `slice_dim` using bit-masks. To enhance readability, in JNifTi, we use explicit subfields
to represent each of the parameter, "Freq", "Phase" and "Slice" inside the "DimInfo" structure
to store the corresponding values. A fixed order of the 3 subfields is not required.

#### Unit  (NIFTI-1 header: xyzt_units)

The NIFTI-1/2 `xyzt_units` is a combined mask of both space and time.
In JNifTi, we map it to a structure with at least two subfields:
`"L"` to store spatial unit, and "T" to store time unit. 

Similar to `DataType`, both `L` and `T` allow to use an integer value, matching
that of the NIFTI-1/2 unit definitions, or a more descriptive string value
to specify the units. The mapping between NIFTI-1/2 units to the string forms
is listed below


|          NIFTI-1/2 Unit Types                | JNifTi Unit  |
|----------------------------------------------|--------------|
|`#define NIFTI_UNITS_UNKNOWN 0               `|  "unknown"   |
|** Length Units **                            |              |                         
|`/*! NIFTI code for meters. */               `|	      |
|`#define NIFTI_UNITS_METER   1               `|  "m"	      |
|`/*! NIFTI code for millimeters. */          `|	      |
|`#define NIFTI_UNITS_MM      2               `|  "mm"        |
|`/*! NIFTI code for micrometers. */          `|	      |
|`#define NIFTI_UNITS_MICRON  3               `|  "um"        |
|** Time Units **                              |              |                         
|`/*! NIFTI code for seconds. */              `|	      |
|`#define NIFTI_UNITS_SEC     8               `|  "s"	      |
|`/*! NIFTI code for milliseconds. */         `|	      |
|`#define NIFTI_UNITS_MSEC   16               `|  "ms"        |
|`/*! NIFTI code for microseconds. */         `|	      |
|`#define NIFTI_UNITS_USEC   24               `|  "us"        |
|** Other Units **                             |              |                         
|`/*! NIFTI code for Hertz. */                `|	      |
|`#define NIFTI_UNITS_HZ     32               `|  "hz"        |
|`/*! NIFTI code for ppm. */                  `|	      |
|`#define NIFTI_UNITS_PPM    40               `|  "ppm"       |
|`/*! NIFTI code for radians per second. */   `|	      |
|`#define NIFTI_UNITS_RADS   48               `|  "rad"       |


#### NIIFormat (NIFTI-1 header: magic)

The "NIIFormat" field stores the original NIFTI-1 format identifier, and is designed for 
compatibility purposes only. The use of this field is depreciated.


#### NIIHeaderSize (NIFTI-1 header: sizeof_hdr)

The "NIIHeaderSize" field stores the original NIFTI-1 header size, and is designed for 
compatibility purposes only. The use of this field is depreciated.

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

### NIFTI_Data



Recommended File Specifiers
------------------------------

For the text-based JNifTi file, the recommended file suffix is **`".jnii"`**; for 
the binary JNifTi file, the recommended file suffix is **`".bnii"`**.

The MIME type for the text-based JNifTi document is 
**`"application/jnifti-text"`**; that for the binary JNifTi document is 
**`"application/jnifti-binary"`**


Summary
----------
