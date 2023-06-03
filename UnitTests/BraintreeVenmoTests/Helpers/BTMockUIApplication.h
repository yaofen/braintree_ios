#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTMockUIApplication : NSObject

//-(id)init; do i ned this

- (void)stubCanOpenURLWith:(BOOL)canOpenURL;

- (void)verifyOpenURLCalledWith:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
