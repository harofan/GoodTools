//
//  AFNetworkTaskProducer.m
//  BBTProject
//
//  Created by Noah Guo on 7/25/16.
//
//

#import "AFNetworkTaskProducer.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFURLResponseSerialization.h>

@interface AFNetworkTaskProducer ()
@property (nonatomic, strong) AFURLSessionManager *session;
@end


@implementation AFNetworkTaskProducer
+ (instancetype)share {
    static AFNetworkTaskProducer *_share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[AFNetworkTaskProducer alloc] init];
    });
    return _share;
}

- (AFURLSessionManager *)session {
    if (_session == nil) {
        _session = [[AFURLSessionManager alloc] init];
        _session.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _session;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completion {
    return [self.session dataTaskWithRequest:request completionHandler:completion];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         progress:(void (^)(NSProgress *uploadProgress))progress
                                       completion:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completion {
    return [self.session uploadTaskWithRequest:request fromData:nil progress:progress completionHandler:completion];
}

- (NSURLSessionDownloadTask *)downloadTaskRequest:(NSURLRequest *)request
                                      destination:(NSString *)destination
                                         progress:(void (^)(NSProgress *downloadProgress))progress
                                       completion:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completion {
    return [self.session downloadTaskWithRequest:request progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:destination];
    } completionHandler:completion];
}

@end
