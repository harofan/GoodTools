//
//  NetworkOperation.h
//  网络框架
//
//  Created by Noah Guo on 7/11/16.
//  Copyright © 2016 Noah. All rights reserved.
//

#import <Foundation/Foundation.h>




typedef NS_ENUM(NSInteger, NHNetworkOperationState) {
    NHNetworkOperationStateCancel = -1,
    NHNetworkOperationStatePrepare,
    NHNetworkOperationStateProcessing,
    NHNetworkOperationStateCompleted
};


/**
 *  数据包装
 */
@interface NHNetworkRespondModel : NSObject

@property (nonatomic, readonly) id model;

@property (nonatomic, readonly) BOOL isCache;

@property (nonatomic, readonly) NSURLResponse *response;

@property (nonatomic, readonly) NSString *requestURLString;

@property (nonatomic, readonly) NSString *requestMethod;

@property (nonatomic, readonly, strong) NSError *error;

@end



/**
 *  观察者，转发内部状态到外部
 */

typedef void(^NHStateBlockType)(NHNetworkOperationState state);

typedef void(^NHProgressBlockType)(double progress);

typedef void(^NHResultBlockTYpe)(NHNetworkRespondModel *respond, BOOL isFinished);



@protocol NHNetworkObserver <NSObject>
@optional

@property (nonatomic, copy) NHStateBlockType stateBlock;

@property (nonatomic, copy) NHProgressBlockType progressBlock;

@property (nonatomic, copy) NHResultBlockTYpe resultBlock;


@end


/**
 *  请求提供器，通过外部构造一个Request
 */
@protocol NHNetworkRequestProvider <NSObject>

- (NSURLRequest *)toRequest:(NSError **)error;

@optional

@property (nonatomic, copy) NSString *downloadDestination;

@end



/**
 *  响应解析器，返回数据解析器，自定义业务数据解析
 */
@protocol NHNetworkRespondParser <NSObject>

- (void)parseWithResponseObject:(id)responseObject
                       response:(NSURLResponse *)response
                          error:(NSError *)error
                         result:(void(^)(NSError *error, id model))result;
@end




/**
 *  任务生产器，可作为第三方网络库的桥接工具
 */
@protocol NHNetworkTaskProducer <NSObject>

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completion;

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         progress:(void (^)(NSProgress *uploadProgress))progress
                                       completion:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completion;

- (NSURLSessionDownloadTask *)downloadTaskRequest:(NSURLRequest *)request
                                      destination:(NSString *)destination
                                         progress:(void (^)(NSProgress *downloadProgress))progress
                                       completion:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completion;

@end




/**
 *  请求缓存配置
 */
typedef NS_ENUM(NSInteger, NHFetchCachePolicyType) {
    NHFetchCachePolicyTypeNothing = -1,
    NHFetchCachePolicyTypeBoth = 0,
    NHFetchCachePolicyTypeAfterFail = 1,
    NHFetchCachePolicyTypeBeforeRequest = 2,
    NHFetchCachePolicyTypeWithoutRequestIfExist = 3,
};

@protocol NHNetworkCacheHandle <NSObject>

@property (nonatomic, assign) NSTimeInterval expiryDate;

@property (nonatomic, assign) NHFetchCachePolicyType fetchCachePolicyType;

- (void)cacheData:(id<NSCopying>)data forKey:(NSString *)key;

- (id<NSCopying>)fetchCacheDataWithKey:(NSString *)key;

- (void)removeCacheDataWithKey:(NSString *)key;

@end





@interface NHNetworkOperation : NSOperation

@property (nonatomic, readonly) NHNetworkOperationState state;

@property (nonatomic, readonly) NHNetworkRespondModel *model;

@property (nonatomic, readonly) double progress;

+ (instancetype)operation;

+ (instancetype)uploadOperation;

+ (instancetype)downloadOperation;

- (NHNetworkOperation *(^)())startOperation;

@end


@interface NHNetworkOperation (Request)

@property (nonatomic, readonly, strong) id<NHNetworkRequestProvider> requestProvider;

- (NHNetworkOperation *(^)(id<NHNetworkRequestProvider>))addRequestProvider;

@end



@interface NHNetworkOperation (Task)

@property (nonatomic, readonly, strong) id<NHNetworkTaskProducer> taskProducer;

- (NHNetworkOperation *(^)(id<NHNetworkTaskProducer>))addTaskProducer;

@end



@interface NHNetworkOperation (Parser)

@property (nonatomic, readonly, strong) id<NHNetworkRespondParser> parser;

- (NHNetworkOperation *(^)(id<NHNetworkRespondParser>))addDataParser;

@end



@interface NHNetworkOperation (Cache)

@property (nonatomic, readonly, strong) id<NHNetworkCacheHandle> cacheHandle;

- (NHNetworkOperation *(^)(id<NHNetworkCacheHandle>))addCache;

@end



@interface NHNetworkOperation (Observer)

@property (nonatomic, readonly, copy) NSArray<NHNetworkObserver> *networkObservers;

- (NHNetworkOperation *(^)(id<NHNetworkObserver>))addObserver;

- (NHNetworkOperation *(^)(NHProgressBlockType))addProgressBlock;

- (NHNetworkOperation *(^)(NHStateBlockType))addStateBlock;

- (NHNetworkOperation *(^)(NHResultBlockTYpe))addResultBlock;


@end
