//
//  PWTextCommand.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/29.
//
//

#import <Foundation/Foundation.h>
#import "PWCommand.h"

// 文本 command
@interface PWTextCommand : PWCommand <PWCommandSendable, PWCommandReceivable>
/*&* 文本text*/
@property (copy, nonatomic) NSString *text;

/**
 init

 @param text 文本text
 @return PWTextCommand Object
 */
- (instancetype)initWithText:(NSString *)text;

@end
