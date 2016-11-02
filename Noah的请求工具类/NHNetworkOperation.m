//
//  NetworkOperation.m
//  网络框架
//
//  Created by Noah Guo on 7/11/16.
//  Copyright © 2016 Noah. All rights reserved.
//

#import "NHNetworkOperation.h"
#import <CommonCrypto/CommonDigest.h>


NSString *getMd5_32Bit_StringWithString(NSString *string)
{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}


@interface NHNetworkRespondModel ()

@property (nonatomic, readwrite, strong) id model;

@property (nonatomic, readwrite, assign) BOOL isCache;

@property (nonatomic, readwrite, strong) NSURLResponse *response;

@property (nonatomic, readwrite, copy) NSString *requestURLString;

@property (nonatomic, readwrite, copy) NSString *requestMethod;

@property (nonatomic, readwrite, strong) NSError *error;

@end

@implementation NHNetworkRespondModel

- (NSString *)description {
    
    return [NSString stringWithFormat:@"\nresponse:%@\nURLString:%@\nMethod:%@", _response, _requestURLString, _requestMethod];
    
}

@end


@interface NHObserver : NSObject<NHNetworkObserver>

@property (nonatomic, copy) NHStateBlockType stateBlock;

@property (nonatomic, copy) NHProgressBlockType progressBlock;

@property (nonatomic, copy) NHResultBlockTYpe resultBlock;


@end
@implementation NHObserver
@end


typedef NS_ENUM(NSInteger, NetworkOperationType) {
    NetworkOperationTypeData,
    NetworkOperationTypeDownload,
    NetworkOperationTypeUpload,
};


@interface NHNetworkOperation ()

@property (nonatomic, strong, readwrite) NHNetworkRespondModel *model;

@property (nonatomic, assign, readwrite) double progress;

@property (nonatomic, assign, readwrite) NHNetworkOperationState state;

@property (nonatomic, strong, readwrite) id<NHNetworkCacheHandle> cacheHandle;

@property (nonatomic, strong, readwrite) id<NHNetworkRespondParser> parser;

@property (nonatomic, strong, readwrite) id<NHNetworkTaskProducer> taskProducer;

@property (nonatomic, strong, readwrite) id<NHNetworkRequestProvider> requestProvider;

@property (nonatomic, copy, readwrite) NSArray<NHNetworkObserver> *networkObservers;

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, assign, getter=isExecuting) BOOL executing;

@property (nonatomic, assign, getter=isFinished) BOOL finished;

@end


@implementation NHNetworkOperation {
    NetworkOperationType _type;
    NSURLRequest *_request;
}

@synthesize finished = _finished, executing = _executing;


#pragma mark - 生命周期
- (instancetype)init {
    NSAssert(NO, @"用类方法初始化");
    self = [super init];
    return nil;
}


+ (instancetype)operation {
    
    return [[NHNetworkOperation alloc] initWithType:NetworkOperationTypeData];
}

+ (instancetype)uploadOperation {
    
    return [[NHNetworkOperation alloc] initWithType:NetworkOperationTypeUpload];
}


+ (instancetype)downloadOperation {
    NHNetworkOperation *op = [[NHNetworkOperation alloc] initWithType:NetworkOperationTypeDownload];
    return op;
    
}

- (NHNetworkOperation *(^)())startOperation {
    return ^() {
        [self start];
        return self;
    };
}

// 私有指定初始化
- (instancetype)initWithType:(NetworkOperationType)type {
    
    self = [super init];
    if (!self) return nil;
    _type = type;
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [_task cancel];
}


#pragma mark - NSOperation
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}


- (void)start {
    // 开始之前已经取消，这种状况一般出现在队列里，当前operation处于等候状态还没start，
    // 但是被外部单独取消了该operation，如果在cancel方法里设isFinished为YES则会将整个队列废掉。
    // 也就是不能在开始前将isFinished设为YES
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
        if (!self.taskProducer || !self.requestProvider) {
            self.finished = YES;
            self.state = NHNetworkOperationStateCancel;
            for (id<NHNetworkObserver> observer in _networkObservers) {
                if ([observer respondsToSelector:@selector(resultBlock)]) {
                    if (observer.resultBlock) {
                        observer.resultBlock(nil, YES);
                    }
                }
            }
            return;
        }
        
        self.state = NHNetworkOperationStateProcessing;
        self.progress = 0;
        self.executing = YES;
        // operation可重复start
        NSError *error;
        _request = _request ? _request : [_requestProvider toRequest:&error];
        if (error) {
            NHNetworkRespondModel *model = [NHNetworkRespondModel new];
            model.error = error;
            [self completedRequestWithRespondModel:model isLast:YES];
        }
        NSParameterAssert(_request);
        
        switch (_type) {
            case NetworkOperationTypeData:
                [self handleNetworkReqest];
                break;
            case NetworkOperationTypeUpload:
                [self handleUploadingRequest];
                break;
            case NetworkOperationTypeDownload:
                [self handleDownloadingRequest];
                break;
        }
    }
}



- (void)cancel {
    
    @synchronized (self) {
        if (self.isFinished) return;
        [super cancel];
        
        if (_task) {
            [_task cancel];
        }
        // 如果正在执行中则表示已经start过，可以将isFinished设为yes
        if (self.isExecuting) {
            self.finished = YES;
            self.executing = NO;
        }
        if (self.state != NHNetworkOperationStateCancel) {
            self.state = NHNetworkOperationStateCancel;
            [self done];
        }
    }
}



#pragma mark - 内部逻辑
- (void)handleNetworkReqest {
    
    if (self->_cacheHandle) {
        // 请求前发送缓存
        if (self->_cacheHandle.fetchCachePolicyType == NHFetchCachePolicyTypeBoth ||
            self->_cacheHandle.fetchCachePolicyType == NHFetchCachePolicyTypeBeforeRequest) {
            NSData *cacheData = [self getCacheData];
            if (cacheData) {
                [self handleResponse:nil data:cacheData error:nil isCache:YES isLast:NO];
            }
            cacheData = nil;
        } else if (self->_cacheHandle.fetchCachePolicyType == NHFetchCachePolicyTypeWithoutRequestIfExist) {
            NSData *cacheData = [self getCacheData];
            if (cacheData) {
                [self handleResponse:nil data:cacheData error:nil isCache:YES isLast:YES];
                return;
            }
            cacheData = nil;
        }
    }
    
    _task = [_taskProducer dataTaskWithRequest:_request completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        self.task = nil;
        BOOL isCache = NO;
        if (error || !response) { // 请求失败后发送缓存
            if (self->_cacheHandle) {
                if (self->_cacheHandle.fetchCachePolicyType == NHFetchCachePolicyTypeAfterFail) {
                    NSData *cacheData = [self getCacheData];
                    isCache = cacheData != nil;
                    responseObject = cacheData;
                    cacheData = nil;
                }
            }
        }
        [self handleResponse:(NSHTTPURLResponse *)response data:responseObject error:error isCache:isCache isLast:YES];
    }];
    [_task resume];
    
}

- (void)handleUploadingRequest {
    
    _task = [_taskProducer uploadTaskWithRequest:_request progress:^(NSProgress *uploadProgress) {
        self.progress = [uploadProgress fractionCompleted];
    } completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        self.task = nil;
        [self handleResponse:(NSHTTPURLResponse *)response data:responseObject error:error isCache:NO isLast:YES];
    }];
    [_task resume];
}

- (void)handleDownloadingRequest {
    
    _task = [_taskProducer downloadTaskRequest:_request destination:_requestProvider.downloadDestination progress:^(NSProgress *downloadProgress) {
        self.progress = [downloadProgress fractionCompleted];
        
    } completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        self.task = nil;
        [self handleResponse:(NSHTTPURLResponse *)response data:responseObject error:error isCache:NO isLast:YES];
    }];
    
    [_task resume];
}

// 请求完成后调用
- (void)handleResponse:(NSHTTPURLResponse *)response
                  data:(NSData *)responseObject
                 error:(NSError *)error
               isCache:(BOOL)isCache
                isLast:(BOOL)isLast {
    
    if (self->_parser) {
        __weak __typeof(self)weakSelf = self;
        [self->_parser parseWithResponseObject:responseObject response:response error:error result:^(NSError *error, id model) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // 数据解析成功后才写入缓存
            if (strongSelf->_cacheHandle && model && !isCache && !error) {
                [strongSelf saveCacheWithData:responseObject];
            }
            NHNetworkRespondModel *respondModel = [[NHNetworkRespondModel alloc] init];
            respondModel.response = response;
            respondModel.requestURLString = response.URL.absoluteString;
            respondModel.requestMethod = self->_request.HTTPMethod;
            respondModel.isCache = isCache;
            
            respondModel.model = model;
            respondModel.error = error;
            
            [strongSelf completedRequestWithRespondModel:respondModel isLast:isLast];
        }];
    } else { // 没有配置解析器的情况
        if (self->_cacheHandle && responseObject) {
            [self saveCacheWithData:responseObject];
        }
        NHNetworkRespondModel *respondModel = [[NHNetworkRespondModel alloc] init];
        respondModel.response = response;
        respondModel.requestURLString = response.URL.absoluteString;
        respondModel.requestMethod = self->_request.HTTPMethod;
        respondModel.isCache = isCache;
        respondModel.error = error;
        respondModel.model = responseObject;
        [self completedRequestWithRespondModel:respondModel isLast:isLast];
    }
    
}

- (void)completedRequestWithRespondModel:(NHNetworkRespondModel *)respond isLast:(BOOL)isLast {
    
    
    if (self.isCancelled) {
        return;
    }
    
    self.model = respond;
    
    if (isLast) {
        
        self.progress = 1;
        [self done];
        
        NSLog(@"请求完成 ============= %@", respond);
    } else {
        
        self.progress = 0.5;
        for (id<NHNetworkObserver> observer in _networkObservers) {
            if ([observer respondsToSelector:@selector(resultBlock)]) {
                if (observer.resultBlock) {
                    observer.resultBlock(respond, NO);
                }
            }
        }
    }
}

- (void)setProgress:(double)progress {
    _progress = progress;
    for (id<NHNetworkObserver> observer in _networkObservers) {
        if ([observer respondsToSelector:@selector(progressBlock)]) {
            if (observer.progressBlock) {
                observer.progressBlock(_progress);
            }
        }
    }
}

- (void)setState:(NHNetworkOperationState)state {
    _state = state;
    for (id<NHNetworkObserver> observer in _networkObservers) {
        if ([observer respondsToSelector:@selector(stateBlock)]) {
            if (observer.stateBlock) {
                observer.stateBlock(_state);
            }
        }
    }
}

- (void)done {
    if (self.state != NHNetworkOperationStateCancel) {
        self.state = NHNetworkOperationStateCompleted;
    }
    for (id<NHNetworkObserver> observer in _networkObservers) {
        if ([observer respondsToSelector:@selector(resultBlock)]) {
            if (observer.resultBlock) {
                observer.resultBlock(self.model, YES);
            }
        }
    }
    
    _task = nil;
    _model = nil;
    _progress = 0;
    
    if (self.isExecuting) self.executing = NO;
    if (!self.isFinished) self.finished = YES;

}



#pragma mark - 工具
- (NSString *)cacheKeyWithRequest:(NSURLRequest *)request {
    
    return getMd5_32Bit_StringWithString(request.URL.absoluteString);
}

- (NSData *)getCacheData {
    NSString *cacheKey = [self cacheKeyWithRequest:self->_request];
    NSDictionary *dict = (NSDictionary *)[self->_cacheHandle fetchCacheDataWithKey:cacheKey];
    if (dict == nil) {
        return nil;
    }
    NSDate *date = dict[@"date"];
    if (date.timeIntervalSince1970 < NSDate.date.timeIntervalSince1970) {
        [self->_cacheHandle removeCacheDataWithKey:cacheKey];
        return nil;
    }
    
    NSData *cacheData = dict[@"data"];
    return cacheData;
}

- (void)saveCacheWithData:(NSData *)data {
    
    NSTimeInterval expiryDate = self->_cacheHandle.expiryDate;
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:expiryDate];
    
    NSString *cacheKey = [self cacheKeyWithRequest:self->_request];
    [self->_cacheHandle cacheData:@{@"data":data,@"date":date} forKey:cacheKey];
}


@end




#pragma mark - Observer
@implementation NHNetworkOperation (Observer)
- (NHNetworkOperation *(^)(id<NHNetworkObserver>))addObserver {
    return ^(id<NHNetworkObserver> observer) {
        NSMutableArray *observers = self.networkObservers.mutableCopy;
        if (observers == nil) {
            observers = [NSMutableArray array];
        }
        self.networkObservers = observers.copy;
        return self;
    };
}

- (NHNetworkOperation *(^)(NHProgressBlockType))addProgressBlock {
    return ^(NHProgressBlockType block){
        NSMutableArray *observers = self.networkObservers.mutableCopy;
        if (observers == nil) {
            observers = [NSMutableArray array];
        }
        NHObserver *ob = NHObserver.new;
        ob.progressBlock = block;
        [observers addObject:ob];
        self.networkObservers = observers.copy;
        return self;
    };
}

- (NHNetworkOperation *(^)(NHStateBlockType))addStateBlock {
    return ^(NHStateBlockType block){
        NSMutableArray *observers = self.networkObservers.mutableCopy;
        if (observers == nil) {
            observers = [NSMutableArray array];
        }
        NHObserver *ob = NHObserver.new;
        ob.stateBlock = block;
        [observers addObject:ob];
        self.networkObservers = observers.copy;
        return self;
    };
    
}

- (NHNetworkOperation *(^)(NHResultBlockTYpe))addResultBlock {
    return ^(NHResultBlockTYpe block){
        NSMutableArray *observers = self.networkObservers.mutableCopy;
        if (observers == nil) {
            observers = [NSMutableArray array];
        }
        NHObserver *ob = NHObserver.new;
        ob.resultBlock = block;
        [observers addObject:ob];
        self.networkObservers = observers.copy;
        return self;
    };
    
}


@end
#pragma mark - 四大组件
@implementation NHNetworkOperation (Request)
- (NHNetworkOperation *(^)(id<NHNetworkRequestProvider>))addRequestProvider {
    return ^(id<NHNetworkRequestProvider>obj) {
        self.requestProvider = obj;
        return self;
    };
}
@end

@implementation NHNetworkOperation (Task)
- (NHNetworkOperation *(^)(id<NHNetworkTaskProducer>))addTaskProducer {
    return ^(id<NHNetworkTaskProducer>obj) {
        self.taskProducer = obj;
        return self;
    };
    
}
@end

@implementation NHNetworkOperation (Parser)
- (NHNetworkOperation *(^)(id<NHNetworkRespondParser>))addDataParser {
    return ^(id<NHNetworkRespondParser>obj) {
        self.parser = obj;
        return self;
    };
}
@end

@implementation NHNetworkOperation (Cache)
- (NHNetworkOperation *(^)(id<NHNetworkCacheHandle>))addCache {
    return ^(id<NHNetworkCacheHandle>obj) {
        self.cacheHandle = obj;
        return self;
    };
    
}

@end


