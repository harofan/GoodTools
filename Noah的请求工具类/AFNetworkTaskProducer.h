//
//  AFNetworkTaskProducer.h
//  BBTProject
//
//  Created by Noah Guo on 7/25/16.
//
//

#import <Foundation/Foundation.h>
#import "NHNetworkOperation.h"

@interface AFNetworkTaskProducer : NSObject <NHNetworkTaskProducer>
+ (instancetype)share;
@end
