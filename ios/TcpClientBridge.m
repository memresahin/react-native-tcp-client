// TcpClientBridge.m
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TcpClient, RCTEventEmitter)

RCT_EXTERN_METHOD(connect:(NSString *)host port:(nonnull NSNumber *)port)
RCT_EXTERN_METHOD(write:(NSString *)message)
RCT_EXTERN_METHOD(disconnect)

@end
