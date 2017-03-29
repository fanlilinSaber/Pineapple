//
//  PWTextCommand.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import <Foundation/Foundation.h>
#import "PWCommand.h"

@interface PWTextCommand : PWCommand <PWCommandSendable>

@property (copy, nonatomic) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end
