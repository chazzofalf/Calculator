//
//  Calculator.m
//  Calculator
//
//  Created by Charles Montgomery on 4/26/13.
//  Copyright (c) 2013 Ohmware. All rights reserved.
//

#import "Calculator.h"

@implementation Calculator
-(int) add:(int)a to:(int)b
{
    return a+b;
}

-(float) divide:(int)a by:(int)b
{
    float result = (float)a/b;
    if (result==INFINITY)
    {
        [NSException raise:@"Cannot divide by zero!" format:@"Not possible to divide %d with %d",a,b];
    }
    return result;
}
@end
