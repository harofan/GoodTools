//
//  BaseNetworkRequest.m
//  BBTProject
//
//  Created by Noah Guo on 7/26/16.
//
//


#import "BaseNetworkRequest.h"
#import "AFNetworkTaskProducer.h"
#import "BaseNetworkRespondParser.h"
#import "NSString+Addition.h"
#import <AFNetworking/AFURLRequestSerialization.h>


@interface UploadFormDataModel ()
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSData *uploadData;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;
@end
@implementation UploadFormDataModel


+ (instancetype)constructFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    
    UploadFormDataModel *model = [[UploadFormDataModel alloc] init];
    model.name = name;
    model.fileName = fileName;
    model.mimeType = mimeType;
    return model;
}

+ (instancetype)constructFormDataWithName:(NSString *)name
                                 fileName:(NSString *)fileName
                                 mimeType:(NSString *)mimeType
                                     data:(NSData *)data {
    UploadFormDataModel *model = [[UploadFormDataModel alloc] init];
    model.name = name;
    model.fileName = fileName;
    model.mimeType = mimeType;
    model.uploadData = data;
    return model;

}

+ (instancetype)constructFormDataWithName:(NSString *)name
                                 fileName:(NSString *)fileName
                                 mimeType:(NSString *)mimeType
                                 filePath:(NSString *)filePath {
    UploadFormDataModel *model = [[UploadFormDataModel alloc] init];
    model.name = name;
    model.fileName = fileName;
    model.mimeType = mimeType;
    model.filePath = filePath;
    return model;
}


@end

@implementation BaseNetworkRequest
- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.timeoutInterval = 60;
    }
    return self;
}


- (NSURLRequest *)toRequest:(NSError *__autoreleasing *)error {
    
    switch (self.requestType) {
        case NetworkRequestTypeData:
            return [self normalRequest:error];
        case NetworkRequestTypeUpload:
            return [self uploadRequest:error];
        case NetworkRequestTypeDownload:
            return [self downloadRequest:error];
    }
}


- (NSURLRequest *)uploadRequest:(NSError *__autoreleasing *)error {
    
    if (!self.formData) {
        return nil;
    }
    NSString *url = self.requestURLString;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"post" URLString:url parameters:self.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *uploadData = self.formData.uploadData;
        if (uploadData == nil) {
            uploadData = [NSData dataWithContentsOfFile:self.formData.filePath];
        }
        if (uploadData) {
            [formData appendPartWithFileData:uploadData name:self.formData.name fileName:self.formData.fileName mimeType:self.formData.mimeType];
        }

    } error:error];
    
    NSDictionary *headers = self.HTTPHeader;
    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];

    if (self.timeoutInterval > 0) {
        request.timeoutInterval = self.timeoutInterval;
    }
    
    [[self class] constructFormDataRequestWithUrlString:request.URL.absoluteString data:[NSData new] name:self.formData.name fileName:self.formData.fileName mimeType:self.formData.mimeType parameters:self.parameters];
    
    NSLog(@"\n\n\n\n——————————————————————————————————————————————————————————\n\nURL:%@\n\nMethod:%@\n\nHeaders:%@\n\nParameters:%@\n\n——————————————————————————————————————————————————————————\n\n\n\n", request.URL, request.HTTPMethod, request.allHTTPHeaderFields, self.parameters);

    return request;
}

- (NSURLRequest *)downloadRequest:(NSError *__autoreleasing *)error {
    
    NSString *url = self.requestURLString;
    NSString *method = [self.HTTPMethod uppercaseString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = method;
    if (self.timeoutInterval > 0) {
        request.timeoutInterval = self.timeoutInterval;
    }
    return request;
}

- (NSURLRequest *)normalRequest:(NSError *__autoreleasing *)error {
    
    NSString *url = self.requestURLString;
    NSString *method = [self.HTTPMethod uppercaseString];
    NSDictionary *params = self.parameters;
    NSDictionary *headers = self.HTTPHeader;
    
    NSParameterAssert(url);
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [serializer setValue:obj forHTTPHeaderField:key];
    }];
    NSMutableURLRequest *request = [serializer requestWithMethod:method URLString:url parameters:params error:error];
    
    NSLog(@"\n\n\n\n——————————————————————————————————————————————————————————\n\nURL:%@\n\nMethod:%@\n\nHeaders:%@\n\nParameters:%@\n\n——————————————————————————————————————————————————————————\n\n\n\n", request.URL, request.HTTPMethod, request.allHTTPHeaderFields, params);
    request.timeoutInterval = self.timeoutInterval;
    return request;

}

- (id<NHNetworkTaskProducer>)taskProducer {
    return _taskProducer ? _taskProducer : [AFNetworkTaskProducer share];
}

- (id<NHNetworkRespondParser>)parser {
    if (self.requestType == NetworkRequestTypeDownload) {
        return nil;
    }
    return _parser ? _parser : [[BaseNetworkRespondParser alloc] init];
}

#pragma mark - TEST
+ (NSMutableURLRequest *)constructFormDataRequestWithUrlString:(NSString *)urlString
                                                          data:(NSData *)data
                                                          name:(NSString *)name
                                                      fileName:(NSString *)fileName
                                                      mimeType:(NSString *)mimeType
                                                    parameters:(NSDictionary *)parameters {
    NSString *boundary = [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    NSMutableData *postBody = [NSMutableData data];
    // body 参数
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@", obj] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    NSLog(@"%@", [[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding]);
    
    // body data
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\";filename=\"%@\"\r\n", name, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:data];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    [request addValue:[NSString stringWithFormat:@"%lud", (unsigned long)postBody.length] forHTTPHeaderField:@"Content-Length"];
    NSLog(@"%@", [[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding]);

    return request;
    
}

@end
