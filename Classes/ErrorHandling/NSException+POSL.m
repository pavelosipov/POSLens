//
//  NSException+POSL.m
//  POSLens
//
//  Created by Pavel Osipov on 30/01/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSException+POSL.h"

@implementation NSException (POSL)

+ (instancetype)posl_exceptionWithFormat:(NSString *)format, ... {
    NSParameterAssert(format);
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

@end
