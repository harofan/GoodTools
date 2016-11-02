//
//  BaseNetworkRespondParser.m
//  BBTProject
//
//  Created by Noah Guo on 7/25/16.
//
//

#import "BaseNetworkRespondParser.h"

@implementation BaseNetworkRespondParser
- (void)parseWithResponseObject:(id)responseObject
                       response:(NSURLResponse *)response
                          error:(NSError *)error
                         result:(void(^)(NSError *error, id model))result {
    if (!responseObject) {
        result(error, nil);
        return;
    }
    
    NSError *jsonError = nil;
    id json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&jsonError];

    if (jsonError) {
        NSString *errorString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"\n***********************************\n\nJosn Error:\n%@\n\n***********************************\n", errorString);
    }
    result(jsonError ? jsonError : error, json);
}

@end
