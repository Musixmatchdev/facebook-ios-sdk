// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "FBSDKUtility.h"

#import "FBSDKAccessToken.h"
#import "FBSDKAuthenticationToken.h"
#import "FBSDKCoreKitBasicsImport.h"
#import "FBSDKInternalUtility+Internal.h"

@implementation FBSDKUtility

+ (NSDictionary<NSString *, id> *)dictionaryWithQueryString:(NSString *)queryString
{
  return [FBSDKBasicUtility dictionaryWithQueryString:queryString];
}

+ (NSString *)queryStringWithDictionary:(NSDictionary<NSString *, id> *)dictionary error:(NSError **)errorRef
{
  return [FBSDKBasicUtility queryStringWithDictionary:dictionary error:errorRef invalidObjectHandler:NULL];
}

+ (NSString *)URLDecode:(NSString *)value
{
  return [FBSDKBasicUtility URLDecode:value];
}

+ (NSString *)URLEncode:(NSString *)value
{
  return [FBSDKBasicUtility URLEncode:value];
}

+ (dispatch_source_t)startGCDTimerWithInterval:(double)interval block:(dispatch_block_t)block
{
  dispatch_source_t timer = dispatch_source_create(
    DISPATCH_SOURCE_TYPE_TIMER, // source type
    0, // handle
    0, // mask
    dispatch_get_main_queue()
  ); // queue

  dispatch_source_set_timer(
    timer, // dispatch source
    dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), // start
    interval * NSEC_PER_SEC, // interval
    0 * NSEC_PER_SEC
  ); // leeway

  dispatch_source_set_event_handler(timer, block);

  dispatch_resume(timer);

  return timer;
}

+ (void)stopGCDTimer:(dispatch_source_t)timer
{
  if (timer) {
    dispatch_source_cancel(timer);
  }
}

+ (NSString *)SHA256Hash:(NSObject *)input
{
  return [FBSDKBasicUtility SHA256Hash:input];
}

+ (NSString *)getGraphDomainFromToken
{
  NSString *graphDomain = FBSDKAuthenticationToken.currentAuthenticationToken.graphDomain;
  if (!graphDomain) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    graphDomain = FBSDKAccessToken.currentAccessToken.graphDomain;
    #pragma clange diagnostic pop
  }
  return graphDomain;
}

+ (NSURL *)unversionedFacebookURLWithHostPrefix:(NSString *)hostPrefix
                                           path:(NSString *)path
                                queryParameters:(NSDictionary<NSString *, id> *)queryParameters
                                          error:(NSError *__autoreleasing *)errorRef
{
  return [FBSDKInternalUtility.sharedUtility unversionedFacebookURLWithHostPrefix:hostPrefix
                                                                             path:path
                                                                  queryParameters:queryParameters
                                                                            error:errorRef];
}

@end
