//
//  PWAbility.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import <Foundation/Foundation.h>
#import "PWCommand.h"

@interface PWAbility : NSObject

+ (PWCommand *)commandWithData:(NSData *)data;

@end
