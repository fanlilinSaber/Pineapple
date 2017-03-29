//
//  PWVideoCommand.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import <Foundation/Foundation.h>
#import "PWCommand.h"

@interface PWVideoCommand : PWCommand <PWCommandReceivable>

@property (copy, nonatomic) NSString *video;

@end
