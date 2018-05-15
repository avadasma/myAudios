//
//  Constant.h
//  Spring3G
//
//  Created by Simon Ding on 14-1-22.
//  Copyright (c) 2014年 SpringAirlines. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kCancelStatue = @"kHTTPRequestCancel";

/*
 常量文件：用于定义一些经常使用的常量、枚举
 */
@interface Constant : NSObject
/*
 网络请求成功Block
 */
typedef void(^SuccessBlock)(id successResult);
/*
 网络请求失败Block
 */
typedef void(^ErrorBlock)(id errorResult);

/* CHCommonNetwork 回调 */
typedef void(^CHSuccessHanderBlock)(id successInfo);

typedef void(^CHFailHanderBlock)(id failInfo);

typedef void(^CHCompleteHanderBlock)(id successInfo,id errorInfo);/* 返回值 正确 和错误 不可共存 */
typedef void(^CHSampleHanderBlock)(id info);

typedef void (^RequestFinishedBlock)(id responsData);

typedef NS_OPTIONS(NSInteger, CHArrayLocation) {
    CHArrayLocationFirst = 1,
    CHArrayLocationMiddle,
    CHArrayLocationLast,
};
//价格日历最大可选时间(机票、机+酒)
#define  PriceAgendaMaxSecletDateCount 180
//价格日历最大可选时间(航班动态)
#define  PriceAgendaMaxSecletDateCountFlightDynamic 90

#define CHFilePathDocuments [NSHomeDirectory() stringByAppendingString:@"/Documents/"]

/*
 * 网络请求异常流
 */
#define CHNetworkDataAbnormal  NSLocalizedStringWithInternational(@"ch_public_wrongString_010001", @"返回数据异常")
#define CHNetworkConnectFail   NSLocalizedStringWithInternational(@"ch_public_wrongString_010002", @"请重试!")
#define CHNetworkNotHaveData   NSLocalizedStringWithInternational(@"ch_public_wrongString_010003", @"未查询到数据")
#define CHNetworkParseFail     NSLocalizedStringWithInternational(@"ch_public_wrongString_010004", @"解析失败")
#define CHNetworkDataFormatError   NSLocalizedStringWithInternational(@"ch_public_wrongString_010005", @"返回数据格式错误")

#define kETagFileName        @"eTag.txt"

/*
 * APPLE Watch 与 iphone连接用到的数据
 */
#define wkCommonRequestKey      @"wkRequestKey"
#define wkAttentFlightsKey      @"wkAttentFlightsKey"
#define wkAttentFlightsValue    @"wkAttentFlightsValue"
#define wkCheckInHistoryKey     @"wkCheckInHistoryKey"
#define wkCheckInHistoryValue   @"wkCheckInHistoryValue"
#define wkCheckInDetailKey      @"wkCheckInDetailKey"
#define wkCheckInDetailValue    @"wkCheckInDetailValue"
#define wkResuestImageKey       @"wkResuestImageKey"
#define wkResuestImageValue     @"wkResuestImageValue"
/*
 * APPLE Watch 与 iphone连接用到的数据
 */
#define wkLocationRequestKey                @"watchKey"
#define wkGetAttentKey                      @"getAttent"
#define wkGetAttentValue                    @"attents"
#define wkGetCheckInHistoryKey              @"getCheckInHistory"
#define wkGetCheckInHistoryValue            @"checkInHistory"
#define wkGetCheckInDetailKey               @"getCheckInDetail"
#define wkGetCheckInDetailValue             @"checkInDetail"
#define wkGetCheckInHistoryParams           @"CheckInHistoryParams"

/*
 * 航班城市查询
 */
//Start
#define kDomesticCityKey                    @"domestic"
#define kDomesticHotCityKey                 @"domesticHotCitys"
#define kInternationalHotCityKey            @"internationalHotCitys"
#define kInternationalCityKey               @"international"
#define kLocalAirlineDataKey                @"Documents/LocalAirlineData"
#define kAirlineVersionKey                  @"AirlineVersion"
#define kAirlineCompanyKey                  @"AirlineCompany"
#define kAirlineCityDictOfNameKey           @"AirlineCityDictOfName"
#define kAirlineCityDictOfThreeCodeKey      @"AirlineCityDictOfThreeCode"
#define kAirlineCityDictOfFormatKey         @"AirlineCityDictOfFormat"
#define kAirlineCityDictOfDomesticKey       @"AirlineCityDictOfDomestic"
#define kAirlineCityDictOfDomesticHotKey    @"AirlineCityDictOfDomesticHot"
#define kAirlineCityDictOfInternationalHotKey    @"AirlineCityDictOfInternationalHot"
#define kAirlineCityDictOfInternationalKey  @"AirlineCityDictOfInternational"
#define kAirlinesDictOfFormatKey            @"AirlinesDictOfFormat"
//End

/*
 * 航班日历查询
 */
//Start
#define kCalendarActURLKey                  @"actUrl"
#define kCalendarActivityKey                @"activity"
#define kCalendarDateKey                    @"date"
#define kCalendarPriceKey                   @"price"
#define kCalendarPriceDisplayKey            @"priceDisplay"
#define kCalendarFestivalKey                @"festival"
#define kCalendarAlmanacKey                 @"almanac"
//End

/*
 * 航班查询
 */
#define kMoneyClassIdTW                       @"141"
#define kMaxCityHistoryRecordsCount           3
#define kFromCityHistoryRecordsKey            @"FromCityHistoryRecords"      //出发城市的历史记录
#define kFromAndToCityHistoryRecordsKey       @"FromAndToCityHistoryRecords" //包含出发和到达城市的历史记录
#define kFromAndToCityHistoryRecordsKeyForTOLand @"FromAndToCityHistoryRecordsKeyForTOLand"//包含出发和到达城市的历史记录(按起降地)
#define kFromAndToCityHistoryRecordsKeyForFlightNO @"FromAndToCityHistoryRecordsKeyForFlightNo"//包含出发和到达城市的历史记录(按航班号)
#define kMaxFromAndToCityHistoryRecordsCount  20                             //包含出发和到达城市的历史记录(最大缓存20条不同航线数据)
#define kFlightNoKey @"FlightNoKey"
#define kFromCityKey                          @"FromCity"
#define kToCityKey                            @"ToCity"
#define kDateSaved                            @"DateSaved"
#define kBackDateSaved                        @"BackDateSaved"
#define kGNCityKey                            @"GN" //国内城市标志值
#define kGJCityKey                            @"GJ" //国际城市标志值
#define kGoDateDataKey                        @"GoDateData"
#define kBackDateDataKey                      @"BackDateData"
#define kFlightFilterKey                      @"FlightFilter"
#define kSecretKey                            @"Secret"
#define kMinPriceArgKey                       @"MinPriceArg"
#define kMinPriceResultKey                    @"MinPriceResult"
#define kFlightsResultKey                     @"FlightsResult"

/*
 由其他页面跳转到航班查询或航班结果时传参key值
 */
#define kFromCityForJumpKey         @"FromCityForJump"
#define kToCityForJumpKey           @"ToCityForJump"
#define kGoDateForJumpKey           @"GoDateForJump"
#define kBackDateForJumpKey         @"BackDateForJump"
#define kFromCityNameForJumpKey     @"FromCityNameForJump"
#define kToCityNameForJumpKey       @"ToCityNameForJump"
#define kFlightProviderJumpKey      @"FlightProviderJump"
#define kFlightArgJumpKey           @"FlightArgJumpKey"
#define kMinCabinsJumpKey           @"MinCabinsForJump"
#define kActivityNameKey            @"activityName"
#define kHotelIdKey                 @"hotelId"
#define kInHotelNightsKey           @"inHotelNights"// 住几晚
#define kInHotelIsRoundTrip         @"isWF"// 是否往返
#define kInHotelhotelDate           @"hotelDate"// 配置的入店日期
#define kInHotelhotelCityId         @"hotelCityId"// 入住城市id
/*
 *机+酒缓存航线
 */
#define kFlightAndHotelFromCityHistoryRecordsKey @"FlightAndHotelFromCityHistoryRecords" //出发城市的历史记录
#define kFlightAndHotelToCityHistoryRecordsKey   @"FlightAndHotelToCityHistoryRecords" //到达城市的历史记录
#define kHotelCityHistoryRecordsKey              @"HotelCityHistoryRecords" //酒店城市历史记录Key
#define kFHFlightCacheFileName                   @"FHFlightCache"  //机+酒缓存历史出发城市航线文件名称
#define kFlightCacheFileName                     @"FlightAirlinesCache"  //机票缓存历史出发城市文件名称
#define kFlightDynamicsCacheFileName @"FlightDynamicsCacheFileName" //航班动态缓存历史出发城市文件名称
#define kFlightDynamicsCacheTOLandFileName             @"FlightDynamicsCacheTOLandFileName"  //航班动态缓存历史出发城市文件名称（按起降地查询）
#define kFlightDynamicsCacheFlightNoFileName             @"FlightDynamicsCacheFlightNoFileName"  //航班动态缓存历史出发城市文件名称(按航班号查询)
/*
 系统版本号
 */
#define GetDefaultFontWithSize(p)          [UIFont fontWithName:@"Arial" size:p]

/*
 本地通知
 */
#define kCityListDidGetSuccessNotification  @"CityListDidGetSuccessNotification"
#define kCityListDidGetFailNotification     @"CityListDidGetFailNotification"
#define kFlightCalendarDidGetNotification   @"FlightCalendarDidGetNotification"
#define kCompanyLogoDidGetNotification      @"CompanyLogoDidGetNotification"

/*
 * 网络请求结果相关常量 Start
 */
#define RESPONSE_SUCCESS              @"1"
#define RESPONSE_FAIL                 @"0"

#define kResponeseStatusKey           @"RequestResultStatus"
#define kResponeseMessageKey          @"ResponeseMessage"
#define kResponeseDataKey             @"ResponeseData"
#define kStatusCodeKey                @"kStatusCodeKey"
/*
 *网络请求结果相关常量 End
 */

/*
 *Engine请求相关常量 Start
 */
#define kSuccessBlockKey              @"SuccessBlock"
#define kErrorBlockKey                @"ErrorBlock"
#define kResponeseBlockKey            @"ResponeseBlock"
#define kURLKey                       @"URL"
#define kIsFullURLKey                 @"IsFullURL"
#define kParamsKey                    @"Params"
/*
 *Engine请求相关常量 End
 */

/*
 *普通字符串常量 Start
 */
#define kTrueValue                    @"Yes"
#define kFalseValue                   @"No"
/*
 *普通字符串常量 End
 */

/*
 *订单中定义的常量 Start
 */
//获取证件类型时，国内、国际、区域传递参数的标识符
#define  DomesticCardTypePragram       @"100"
#define  InternationCardTypePragram    @"001"
#define  AreaCardTypePragram           @"010"



/*
 *活动舱
 */
#define kFlightDateKey                        @"Date"
#define kFlightWeekKey                        @"Week"
/*
 *航班
 */
#define FIRST_FLIGHT                           0
#define SECOND_FLIGHT                          1
#define RESERVATION_TYPE_SINGLE                0
#define RESERVATION_TYPE_DOUBLE                1
#define RESERVATION_TYPE_LC                    2
/*
 *URL 解析
 */
#define kURLStatusKey                          @"URLStatus"
#define kURLTypeKey                            @"URLType"
#define kURLResultKey                          @"URLResult"
#define kURLAppActionKey                       @"URLAppAction"
/*
 * 第三方支付支付成功后，发送的通知key
 */
#define kAppPayResultSuccess                  @"AppPayResultSuccess"
/*
 * 第三方支付支付失败后，发送的通知key
 */
#define kAppPayResultFail                     @"AppPayResultFail"
/*
 * 消息中心
 */
#define DBNAME        @"5.3.0_messages.sqlite" // 消息中心消息数据库
#define CUSTOM_MESSAGE_PUSH_CACHE   @"CustomMessagePushCache"
#define CUSTOM_MESSAGER_CACHE       @"CustomMessageCache"
#define DidReceiveCustomMessage     @"didReceiveCustomMessage"
#define MSGID         @"msg_id"          // 消息id
#define MSGTITLE      @"msg_title"       // 消息title
#define MSGCONTENT    @"msg_content"     // 消息内容
#define MSGTIME       @"msg_time"        // 接受消息时间
#define MSGISREADED   @"msg_isReaded"    // 消息是否已读
#define MSGNOTICEKEY  @"msg_noticeKey"   // 消息跳转类型
#define MSGPARAMS     @"msg_params"      // 消息附加参数
#define MSGMARK       @"msg_mark"        // 消息备注
#define TABLENAME     @"MESSAGESINFO"

#define SDKConfigKeyString @"kSDKConfigKeyString" //存储sdk开关的键值

#define MJRefreshFooterPullToRefresh  NSLocalizedStringWithInternational(@"common_pullController_controller_010010", @"上拉可以加载更多数据");
#define MJRefreshFooterReleaseToRefresh NSLocalizedStringWithInternational(@"common_pullController_controller_010011", @"松开立即加载更多数据");
#define MJRefreshFooterRefreshing  NSLocalizedStringWithInternational(@"common_pullController_controller_010012", @"正在帮你加载数据...");
#define MJRefreshFooterNoMore NSLocalizedStringWithInternational(@"common_pullController_controller_010013", @"没有更多数据了");

#define MJRefreshHeaderRefreshing NSLocalizedStringWithInternational(@"common_pullController_controller_010012", @"正在帮你加载数据...");
#define MJRefreshHeaderPullToRefresh  NSLocalizedStringWithInternational(@"common_pullController_controller_010014", @"下拉可以刷新");
#define MJRefreshHeaderReleaseToRefresh NSLocalizedStringWithInternational(@"common_pullController_controller_010015", @"松开立即刷新");

/*
 * @brief购买增值服务页面来源
 */
typedef enum {
    ComeFromAirOrderDetail = 1, //来自订单详情
    ComeFromHadPayAirOrderDetail, //来自已经支付订单详情
    ComeFromNormalOrder,        //来自正常订单流程
    ComeFromUnloginOrder,       //来自未登陆二次购买
    ComeFromloginedOrder,       //来自已登陆二次购买
    ComeFromFlightAndHotel,     //来自机加酒流程
} ComeFromSourceEnum;
/*
 * @brief 错误类型
 */
typedef enum{
    kMessageErrorType = 0,
    kHtmlURLErrorType
}ErrorType;
/*
 * @brief航班结果排序 Start
 */
typedef enum{
    kTakeOffTimeAscType = 0,
    kTakeOffTimeDescType,
    kPriceAscType,
    kPriceDescType
}FlightSortType;

//航班类型
typedef NS_ENUM(NSInteger,CHFlightType) {
    CHFlightType9C = 1,      //普通航班
    CHFlightTypeTransfer = 2,//中转联程
    CHFlightTypeKT = 3,      //空铁
    CHFlightTypeKB = 4,      //空巴
    CHFlightTypeIJ = 5,      //IJ航班
    CHFlightTypeError = 9999 //错误类型
};

/**
 航班动态页面来源
 - CHFlightDynamicFromPalceXingCheng: 行程
 */
typedef NS_ENUM(NSInteger,CHFlightDynamicFromPalce) {
    CHFlightDynamicFromPalceXingCheng = 0,//行程入口
    CHFlightDynamicFromPalceQuery = 1,//航班查询入口
    CHFlightDynamicFromPalceMessage = 2, //消息中心入口
    CHFlightDynamicFromPalceHome = 3   //首页入口
};
typedef enum : NSUInteger {
    FirstFlightDisplayVC = 1, //第一程航班展示ViewCotroller界面
    SecondFlightDisplayVC, //第二程航班展示ViewCotroller界面
} FlightDisplayVCType;

/**
 历史记录缓存类别

 - CacheTypeHistoryCityFlightBook: 机票预订页面
 - CacheTypeHistoryCityFlightTOLand: 航班动态-按起降地
 - CacheTypeHistoryCityFlightNo: 航班动态-按航班号查询
 */
typedef NS_ENUM(NSInteger,CacheTypeHistoryCity) {
    CacheTypeHistoryCityFlightBook = 0,//机票预订
    CacheTypeHistoryCityFlightTOLand = 1//按起降地
};


@end
