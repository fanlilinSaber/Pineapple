//
//  PWASRStatusCommand.h
//  Unity-iPhone
//
//  Created by 范李林 on 2017/10/25.
//
//

#import <Pineapple/Pineapple.h>

@interface PWASRStatusCommand : PWCommand <PWCommandReceivable, PWCommandSendable>
/*&* <##>*/
@property (nonatomic, assign) BOOL isOpen;
/*&* <##>*/
@property (nonatomic, assign) int topicNumber;

- (instancetype)initWithParams:(NSDictionary *)params;
@end
