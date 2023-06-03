#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTMockUIApplication : NSObject

- (void)stubCanOpenURLWith:(BOOL)canOpenURL;

@property(readonly, nonatomic) UIApplication *mock;

@end

NS_ASSUME_NONNULL_END
