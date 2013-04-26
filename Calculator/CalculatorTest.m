//
//  CalculatorTest.m
//  Calculator
//
//  Created by Charles Montgomery on 4/26/13.
//  Copyright (c) 2013 Ohmware. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Calculator.h"
@interface CalculatorTest : SenTestCase
{
    Calculator *calculator;
}
-(void) testAdd;
-(void) testDivide;
-(void) testDivideByZero;
@end
@implementation CalculatorTest
-(void)setUp
{
    calculator = [[Calculator alloc]init];
}
-(void)tearDown
{
    //[calculator release]; //Unnecessary in ARC mode [Does not compile here anyway]!
}
-(void) testAdd
{
    int expected = 11;
    int result = [calculator add:5 to:6];
    STAssertEquals(expected, result, @"We expected %d, but it was %d",expected,result);
}
-(void) testDivide
{
    float expected = 2.5;
    float result = [calculator divide:5 by:2];
    STAssertEquals(expected, result, @"We expected %d, but it was %d",expected,result);
}
-(void) testDivideByZero
{
    STAssertThrows([calculator divide:5 by:0], @"We expected an exception to be raised when dividing by 0");
}
@end
