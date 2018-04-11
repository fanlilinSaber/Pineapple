//
//  PWUserLoginStatusCommand.h
//  Unity-iPhone
//
//  Created by 范李林 on 2018/4/10.
//

#import <Pineapple/Pineapple.h>

@interface PWUserLoginStatusCommand : PWCommand <PWCommandReceivable, PWCommandSendable>

- (instancetype)initWithParams:(NSDictionary *)params;

- (instancetype)initWithUserToken:(NSString *)userToken;

/*&* <##>*/
@property (nonatomic, assign) BOOL isValid;
/*&* <##>*/
@property (nonatomic, copy) NSString *userToken;
@end
