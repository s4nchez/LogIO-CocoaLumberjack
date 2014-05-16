#import "LogIOLogger.h"
#import "GCDAsyncSocket.h"

@interface LogIOLogger ()

@property(nonatomic, strong) GCDAsyncSocket *socket;
@property(nonatomic) long messageTag;
@property(nonatomic) NSString *nodeName;
@property(nonatomic) NSString *streamName;

@end

@implementation LogIOLogger

static LogIOLogger *sharedInstance;

static NSString *const REGISTER_NODE_PATTERN = @"+node|%@|%@\r\n";
static NSString *const LOG_FORMAT = @"+log|%@|%@|%d|%@\r\n";

+ (LogIOLogger *)sharedInstance {
    return sharedInstance;
}

+ (void)connectTo:(NSString *)host port:(uint16_t)port {
    [sharedInstance socketConnect:host port:port];
}

- (void)nodeName:(NSString *)name {
    self.nodeName = name;
}

- (void)streamName:(NSString *)name {
    self.streamName = name;
}

+ (void)initialize {
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedInstance = [[LogIOLogger alloc] init];
    }
}

- (id)init {
    if (sharedInstance != nil) {
        return nil;
    }
    return self;
}

+ (void)configureNode:(NSString *)nodeName stream:(NSString *)streamName {
    [sharedInstance nodeName:nodeName];
    [sharedInstance streamName:streamName];
}

- (void)socketConnect:(NSString *)host port:(uint16_t)port {
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.messageTag = 0;
    NSError *err = nil;
    NSLog(@"Connecting to %@:%d", host, port);
    if (![self.socket connectToHost:host onPort:port error:&err]) {
        NSLog(@"Could not connect %@", err);
    }
    [self sendMessage:[NSString stringWithFormat:REGISTER_NODE_PATTERN, self.nodeName, self.streamName]];
}

- (void)sendMessage:(NSString *)message {
    self.messageTag++;
    NSLog(@"[%li] %@", self.messageTag, message);
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:self.messageTag];
}


- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected.");

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"Disconnected (%@)", err);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"[%li] Sent.", tag);
}


- (void)logMessage:(DDLogMessage *)logMessage {
    if (!self.socket) {
        NSLog(@"Not connected. Ignoring...");
        return;
    }

    NSLog(@"Logging %@", logMessage);

    NSString *logMsg = logMessage->logMsg;
    int logLevel = logMessage->logLevel;

    if (self->formatter)
        logMsg = [self->formatter formatLogMessage:logMessage];

    if (logMsg) {
        [self sendMessage:[NSString stringWithFormat:LOG_FORMAT, self.streamName, self.nodeName, logLevel, logMsg]];
    }
}

- (NSString *)loggerName {
    return @"cocoa.lumberjack.LogIOLogger";
}


@end