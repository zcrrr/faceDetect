
#ifndef INCLUDE_CV_COMMON_H_
#define INCLUDE_CV_COMMON_H_

/// @defgroup cv_common cv common
/// @brief common definitions for cv libs
/// @{


#ifdef _MSC_VER
#	ifdef __cplusplus
#		ifdef CV_STATIC_LIB
#			define CV_SDK_API  extern "C"
#		else
#			ifdef SDK_EXPORTS
#				define CV_SDK_API extern "C" __declspec(dllexport)
#			else
#				define CV_SDK_API extern "C" __declspec(dllimport)
#			endif
#		endif
#	else
#		ifdef CV_STATIC_LIB
#			define CV_SDK_API
#		else
#			ifdef SDK_EXPORTS
#				define CV_SDK_API __declspec(dllexport)
#			else
#				define CV_SDK_API __declspec(dllimport)
#			endif
#		endif
#	endif
#else /* _MSC_VER */
#	ifdef __cplusplus
#		ifdef SDK_EXPORTS
#			define CV_SDK_API  extern "C" __attribute__((visibility ("default")))
#		else
#			define CV_SDK_API extern "C"
#		endif
#	else
#		ifdef SDK_EXPORTS
#			define CV_SDK_API __attribute__((visibility ("default")))
#		else
#			define CV_SDK_API
#		endif
#	endif
#endif

/// cv handle declearation
typedef void *cv_handle_t;

/// cv result declearation
typedef int   cv_result_t;

#define CV_OK (0)		///< 正常运行
#define CV_E_INVALIDARG (-1)	///< 无效参数
#define CV_E_HANDLE (-2)	///< 句柄错误
#define CV_E_OUTOFMEMORY (-3)	///< 内存不足
#define CV_E_FAIL (-4)		///< 内部错误
#define CV_E_DELNOTFOUND (-5)	///< 定义缺失

/// cv rectangle definition
typedef struct cv_rect_t {
	int left;	///< 矩形最左边的坐标
	int top;	///< 矩形最上边的坐标
	int right;	///< 矩形最右边的坐标
	int bottom;	///< 矩形最下边的坐标
} cv_rect_t;

/// cv float type point definition
typedef struct cv_pointf_t {
	float x;	///< 点的水平方向坐标，为浮点数
	float y;	///< 点的竖直方向坐标，为浮点数
} cv_pointf_t;

/// cv integer type point definition
typedef struct cv_pointi_t {
	int x;		///< 点的水平方向坐标，为整数
	int y;		///< 点的竖直方向坐标，为整数
} cv_pointi_t;

/// cv pixel format definition
typedef enum {
	CV_PIX_FMT_GRAY8,	///< Y    1        8bpp ( 单通道8bit灰度像素 )
	CV_PIX_FMT_YUV420P,	///< YUV  4:2:0   12bpp ( 3通道, 一个亮度通道, 另两个为U分量和V分量通道, 所有通道都是连续的 )
	CV_PIX_FMT_NV12,	///< YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为UV分量交错 )
	CV_PIX_FMT_NV21,	///< YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 )
	CV_PIX_FMT_BGRA8888,	///< BGRA 8:8:8:8 32bpp ( 4通道32bit BGRA 像素 )
	CV_PIX_FMT_BGR888	///< BGR  8:8:8   24bpp ( 3通道24bit BGR 像素 )
}cv_pixel_format;

// ===================== color convert ====================
/// 支持的颜色转换格式
typedef enum {
	CV_COLOR_CONVERT_BGRA_YUV420P = 0,	///< CV_PIX_FMT_BGRA8888到CV_PIX_FMT_YUV420P转换
	CV_COLOR_CONVERT_BGR_YUV420P = 1,	///< CV_PIX_FMT_BGR888到CV_PIX_FMT_YUV420P转换
	CV_COLOR_CONVERT_BGRA_NV12 = 2,		///< CV_PIX_FMT_BGRA8888到CV_PIX_FMT_NV12转换
	CV_COLOR_CONVERT_BGR_NV12 = 3,		///< CV_PIX_FMT_BGR888到CV_PIX_FMT_NV12转换
	CV_COLOR_CONVERT_BGRA_NV21 = 4,		///< CV_PIX_FMT_BGRA8888到CV_PIX_FMT_NV21转换
	CV_COLOR_CONVERT_BGR_NV21 = 5,		///< CV_PIX_FMT_BGR888到CV_PIX_FMT_NV21转换
	CV_COLOR_CONVERT_YUV420P_BGRA = 6,	///< CV_PIX_FMT_YUV420P到CV_PIX_FMT_BGRA8888转换
	CV_COLOR_CONVERT_YUV420P_BGR = 7,	///< CV_PIX_FMT_YUV420P到CV_PIX_FMT_BGR888转换
	CV_COLOR_CONVERT_NV12_BGRA = 8,		///< CV_PIX_FMT_NV12到CV_PIX_FMT_BGRA8888转换
	CV_COLOR_CONVERT_NV12_BGR = 9,		///< CV_PIX_FMT_NV12到CV_PIX_FMT_BGR888转换
	CV_COLOR_CONVERT_NV21_BGRA = 10,	///< CV_PIX_FMT_NV21到CV_PIX_FMT_BGRA8888转换
	CV_COLOR_CONVERT_NV21_BGR = 11,		///< CV_PIX_FMT_NV21到CV_PIX_FMT_BGR888转换
	CV_COLOR_CONVERT_BGRA_GRAY = 12,	///< CV_PIX_FMT_BGRA8888到CV_PIX_FMT_GRAY8转换
	CV_COLOR_CONVERT_BGR_BGRA = 13,		///< CV_PIX_FMT_BGR888到CV_PIX_FMT_BGRA8888转换
	CV_COLOR_CONVERT_BGRA_BGR = 14,		///< CV_PIX_FMT_BGRA8888到CV_PIX_FMT_BGR888转换
	CV_COLOR_CONVERT_YUV420P_GRAY = 15,	///< CV_PIX_FMT_YUV420P到CV_PIX_FMT_GRAY8转换
	CV_COLOR_CONVERT_NV12_GRAY = 16,	///< CV_PIX_FMT_NV12到CV_PIX_FMT_GRAY8转换
	CV_COLOR_CONVERT_NV21_GRAY = 17,	///< CV_PIX_FMT_NV21到CV_PIX_FMT_GRAY8转换
	CV_COLOR_CONVERT_BGR_GRAY = 18,		///< CV_PIX_FMT_BGR888到CV_PIX_FMT_GRAY8转换
	CV_COLOR_CONVERT_GRAY_YUV420P = 19,	///< CV_PIX_FMT_GRAY8到CV_PIX_FMT_YUV420P转换
	CV_COLOR_CONVERT_GRAY_NV12 = 20,	///< CV_PIX_FMT_GRAY8到CV_PIX_FMT_NV12转换
	CV_COLOR_CONVERT_GRAY_NV21 = 21,	///< CV_PIX_FMT_GRAY8到CV_PIX_FMT_NV21转换
	CV_COLOR_CONVERT_NV12_YUV420P = 22,	///< CV_PIX_FMT_NV12到CV_PIX_FMT_YUV420P转换
	CV_COLOR_CONVERT_NV21_YUV420P = 23	///< CV_PIX_FMT_NV21到CV_PIX_FMT_YUV420P转换
}cv_color_convert;

/// @brief 进行颜色格式转换
/// @param image_src 用于待转换的图像数据
/// @param image_dst 转换后的图像数据
/// @param image_width 用于转换的图像的宽度(以像素为单位)
/// @param image_height 用于转换的图像的高度(以像素为单位)
/// @param color_convert_type 需要转换的颜色格式
/// @return 正常返回CV_OK，否则返回错误类型
cv_result_t
cv_color_convertor(
	const unsigned char *image_src,
	unsigned char *image_dst,
	int image_width,
	int image_height,
	cv_color_convert color_convert_type
);

typedef struct cv_feature_header_t {
	int ver;		///< 版本信息
	int idx;		///< 数组下标索引
	int len;		///< CV_FEATURE全部内容的长度，包括feature_header和特征数组，按字节计算，与sizeof(cv_feature_header_t)定义不同
} cv_feature_header_t;

///< cv_feature_header_t为CV_FEATURE数据头解析，实际CV_FEATURE还包含了特征信息
///< cv_feature_t is an opaque structure, use CV_FEATURE_XXX macros to
///< get its size and version
typedef struct cv_feature_t cv_feature_t;

#define CV_FEATURE_HEADER(pf) ((cv_feature_header_t*)(pf))
#define CV_FEATURE_SIZE(pf)   (CV_FEATURE_HEADER(pf)->len)
#define CV_ENCODE_FEATURE_SIZE(pf) ((CV_FEATURE_HEADER(pf)->len+2)/3*4 + 1)

typedef struct cv_clustering_result_t {
	unsigned int count;		///< 人脸数量
	int *idxs;			///< 人脸索引数组
	unsigned int group_flags;	///< 保留参数
} cv_clustering_result_t;

/// @brief 图像分类标签结果
typedef struct cv_classify_result_t{
	int id;  ///标签
	float score;  /// 置信度
}cv_classify_result_t;

/// @brief 特征信息编码成字符串，编码后的字符串用于保存
/// @param feature 输入的特征信息
/// @param feature_str 输出的编码后的字符串,由用户分配和释放
cv_result_t
cv_feature_serialize(
	const cv_feature_t *feature,
	char *feature_str
);

/// @brief 解码字符串成特征信息
/// @param feature_str 输入的待解码的字符串，api负责分配内存，需要调用cv_verify_release_feature释放
cv_feature_t *
cv_feature_deserialize(
	const char *feature_str
);

/// @}
#endif  // INCLUDE_CV_COMMON_H_

