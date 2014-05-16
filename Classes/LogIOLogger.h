#import <Foundation/Foundation.h>
#import "DDLog.h"
#import "GCDAsyncSocket.h"


@interface LogIOLogger : DDAbstractLogger <DDLogger, GCDAsyncSocketDelegate>

+ (LogIOLogger *)sharedInstance;

+ (void)connectTo:(NSString *)host port:(uint16_t)port;

+ (void)configureNode:(NSString *)nodeName stream:(NSString *)streamName;

@end