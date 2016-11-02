//
//  BaseNetworkRequest.h
//  BBTProject
//
//  Created by Noah Guo on 7/26/16.
//
//

#import <Foundation/Foundation.h>
#import "NHNetworkOperation.h"

typedef NS_ENUM(NSInteger, NetworkRequestType) {
    NetworkRequestTypeData = 0,
    NetworkRequestTypeDownload,
    NetworkRequestTypeUpload
};

@interface UploadFormDataModel : NSObject
+ (instancetype)constructFormDataWithName:(NSString *)name
                                 fileName:(NSString *)fileName
                                 mimeType:(NSString *)mimeType
                                     data:(NSData *)data;

+ (instancetype)constructFormDataWithName:(NSString *)name
                                 fileName:(NSString *)fileName
                                 mimeType:(NSString *)mimeType
                                     filePath:(NSString *)filePath;

@end


@interface BaseNetworkRequest : NSObject <NHNetworkRequestProvider>
@property (nonatomic, copy) NSString *requestURLString;
@property (nonatomic, copy) NSString *HTTPMethod;
@property (nonatomic, copy) NSString *downloadDestination;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *HTTPHeader;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *parameters;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, strong) id<NHNetworkRespondParser> parser;
@property (nonatomic, strong) id<NHNetworkTaskProducer> taskProducer;
@property (nonatomic, strong) id<NHNetworkCacheHandle> cacheHandle;

@property (nonatomic, assign) NetworkRequestType requestType;
@property (nonatomic, strong) UploadFormDataModel *formData;

@end
