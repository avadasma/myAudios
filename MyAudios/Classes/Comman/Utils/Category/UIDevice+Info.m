//
//  UIDevice+Info.m
//  MyAudios
//
//  Created by chang on 2018/3/19.
//  Copyright © 2018年 chang. All rights reserved.
//

#import "UIDevice+Info.h"
#import <Security/Security.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

static const char kKeychainUDIDItemIdentifier[]  = "UUID";
static NSString * currentDeviceUUID = nil;//保存uuid的静态变量
static NSString * currentSecretDeviceUUID = nil;//保存加密后的uuid的静态变量
static NSString * keyHeader  = @"keyHeader";
@implementation UIDevice (Info)

#pragma mark - 获取当前的唯一标识符UUID
- (NSString *)getCurrentDeviceUUID{
    @synchronized(self){
        if (!currentDeviceUUID || [currentDeviceUUID isEqualToString:@""]) {
            currentDeviceUUID = [[UIDevice currentDevice] getUUIDFromKeyChain];
            NSLog(@"uuid 读取成功! uuid = %@",currentDeviceUUID);
            if (!currentDeviceUUID || [currentDeviceUUID isEqualToString:@""]){
                currentDeviceUUID = [[UIDevice currentDevice] getUUID];
                if ([[UIDevice currentDevice] setUUIDToKeyChain:currentDeviceUUID]) {
                    NSLog(@"uuid 保存成功! uuid = %@",currentDeviceUUID);
                }else {
                    NSLog(@"uuid 保存失败! uuid = %@",currentDeviceUUID);
                }
            }
        }else{
            NSLog(@"uuid 已经存在内存中! uuid = %@",currentDeviceUUID);
        }
        
        currentDeviceUUID = [currentDeviceUUID stringByReplacingOccurrencesOfString:@"-" withString:@"_"];// V525为极光alias而特加 chang
        return currentDeviceUUID;
    }
}

#pragma mark - 获取钥匙串中的uuid
- (NSString*)getUUIDFromKeyChain {
    
    NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
    [dictForQuery setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    [dictForQuery setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]
                    forKey:(__bridge NSString *)(kSecAttrDescription)];
    
    NSData *keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
                                            length:strlen(kKeychainUDIDItemIdentifier)];
    [dictForQuery setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
    
    NSString *accessGroup = [self getKeyChainUDIDAccessGroup];
    if (accessGroup != nil)
    {
#if TARGET_IPHONE_SIMULATOR
        //如果时模拟机  则不操作
#else
        //设置钥匙串组
        [dictForQuery setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
    }
    
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(__bridge id)kSecMatchCaseInsensitive];
    [dictForQuery setValue:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    OSStatus queryErr   = noErr;
    NSData   *udidValue = nil;
    NSString *udid      = nil;
    CFTypeRef uDidValue = (__bridge_retained CFTypeRef)udidValue;
    SecItemCopyMatching((__bridge CFDictionaryRef)dictForQuery, &uDidValue);
    
    udidValue = (__bridge_transfer NSData *) uDidValue;
    NSMutableDictionary *dict = nil;
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    CFTypeRef dictRef = (__bridge_retained CFTypeRef)dict;
    queryErr = SecItemCopyMatching((__bridge CFDictionaryRef)dictForQuery, &dictRef);
    
    if(dictRef != nil){
        CFRelease(dictRef);
    }
    
    if (queryErr == errSecItemNotFound) {
        NSLog(@"KeyChain Item: %@ not found!!!", [NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]);
    }
    else if (queryErr != errSecSuccess) {
        NSLog(@"KeyChain Item query Error!!! Error code:%d", (int)queryErr);
    }
    if (queryErr == errSecSuccess) {
        NSLog(@"KeyChain Item: %@", udidValue);
        
        if (udidValue) {
            udid = [NSString stringWithUTF8String:[udidValue bytes]];
        }
    }
    return udid;
}

#pragma mark - 获取设备Id
- (NSString *)getUUID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [defaults stringForKey:@"uuid"];
    if (uuid == nil) {
        CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);// CFUUID从iOS2.0开始可以使用，但是每次调用CFUUIDCreate()都会重新生成
        uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        [defaults setObject:uuid forKey:@"uuid"];
        [defaults synchronize];
        CFRelease(cfuuid);
    }
    return uuid;
}
#pragma mark - 设置UUID到钥匙串
- (BOOL)setUUIDToKeyChain:(NSString*)udid
{
    NSMutableDictionary *dictForAdd = [[NSMutableDictionary alloc] init];
    
    [dictForAdd setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [dictForAdd setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:(__bridge NSString *)(kSecAttrDescription)];
    
    [dictForAdd setValue:@"UUID" forKey:(__bridge id)kSecAttrGeneric];
    
    [dictForAdd setObject:@"" forKey:(__bridge id)kSecAttrAccount];
    [dictForAdd setObject:@"" forKey:(__bridge id)kSecAttrLabel];
    
    NSString *accessGroup = [self getKeyChainUDIDAccessGroup];
    if (accessGroup != nil)
    {
#if TARGET_IPHONE_SIMULATOR
        //如果是模拟器则不操作
#else
        [dictForAdd setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
    }
    
    const char *udidStr = [udid UTF8String];
    NSData *keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
    [dictForAdd setValue:keyChainItemValue forKey:(__bridge id)kSecValueData];
    
    OSStatus writeErr = noErr;
    if ([self getUUIDFromKeyChain]) {
        [self updateUUIDInKeyChain:udid];
        return YES;
    }
    else {
        writeErr = SecItemAdd((__bridge CFDictionaryRef)dictForAdd, NULL);
        if (writeErr != errSecSuccess) {
            NSLog(@"Add KeyChain Item Error!!! Error Code:%d", (int)writeErr);
            return NO;
        }
        else {
            NSLog(@"Add KeyChain Item Success!!!");
            return YES;
        }
    }
    return NO;
}
#pragma mark - 获取plist文件里的keychain-access-groups数据
- (NSString *)getKeyChainUDIDAccessGroup {
    NSString * errorDic = nil;
    NSPropertyListFormat format;
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"KeychainAccessGroups" ofType:@"plist"];
    NSData * plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary * test = [NSPropertyListSerialization propertyListFromData:plistXML
                                                           mutabilityOption:
                           NSPropertyListMutableContainersAndLeaves format:&format
                                                           errorDescription:&errorDic];
    NSArray * keyChainUDIDAccessGroups = [test objectForKey:@"keychain-access-groups"];
    NSString * keyChainUDIDAccessGroup = nil;
    if ([keyChainUDIDAccessGroups count] > 0) {
        keyChainUDIDAccessGroup = [keyChainUDIDAccessGroups objectAtIndex:0];
    }
    return keyChainUDIDAccessGroup;
}
#pragma mark - 更新钥匙串中的UUID
- (BOOL)updateUUIDInKeyChain:(NSString*)newUDID
{
    
    NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
    
    [dictForQuery setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
                                            length:strlen(kKeychainUDIDItemIdentifier)];
    [dictForQuery setValue:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(__bridge id)kSecMatchCaseInsensitive];
    [dictForQuery setValue:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    NSDictionary *queryResult = nil;
    CFTypeRef queryResultRef = (__bridge_retained CFTypeRef)(queryResult);
    SecItemCopyMatching((__bridge CFDictionaryRef)dictForQuery, &queryResultRef);
    queryResult = (__bridge_transfer NSDictionary *)(queryResultRef);
    
    if (queryResult) {
        
        NSMutableDictionary *dictForUpdate = [[NSMutableDictionary alloc] init];
        [dictForUpdate setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:(__bridge NSString *)(kSecAttrDescription)];
        [dictForUpdate setValue:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
        
        const char *udidStr = [newUDID UTF8String];
        NSData *keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
        [dictForUpdate setValue:keyChainItemValue forKey:(__bridge id)kSecValueData];
        
        OSStatus updateErr = noErr;
        
        NSMutableDictionary *updateItem = [NSMutableDictionary dictionaryWithDictionary:queryResult];
        
        [updateItem setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        updateErr = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)dictForUpdate);
        if (updateErr != errSecSuccess) {
            NSLog(@"Update KeyChain Item Error!!! Error Code:%d", (int)updateErr);
            return NO;
        }
        else {
            NSLog(@"Update KeyChain Item Success!!!");
            return YES;
        }
    }
    return NO;
}
@end
