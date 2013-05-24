//
//  CalculatorTest.m
//  Calculator
//
//  Created by Charles Montgomery on 4/26/13.
//  Copyright (c) 2013 Ohmware. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Calculator.h"
#import <vMAT.h>
#import <Eigen/Core>
namespace
{
    using namespace Eigen;
    using namespace vMAT;
}
@interface CalculatorTest : SenTestCase
{
    Calculator *calculator;
}
@end

@implementation CalculatorTest
-(void)setUp
{
    calculator = [[Calculator alloc] init];
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
    STAssertEquals(expected, result, @"We expected %f, but it was %f",expected,result);
}

-(void) testDivideByZero
{
    STAssertThrows([calculator divide:5 by:0], @"We expected an exception to be raised when dividing by 0");
}

-(void) testVMat
{
    const float iniM[] = {
        2,11,7,14,
        3,10,6,15,
        13,8,12,1
    };
    vMAT_Array * matM = [vMAT_Array arrayWithSize:vMAT_MakeSize(4,3)
                                             type:miSINGLE
                                             data:[NSData dataWithBytes:iniM length:sizeof(iniM)]];
    NSLog(@"matM:\n%@",matM.dump);
    Mat<float> M = matM;
    Matrix<float,4,3> X = M.array() * M.array();
    vMAT_Array * matX = vMAT_cast(X);
    NSLog(@"matX:\n%@",matX.dump);
    vMAT_Array * matXv = [vMAT_Array arrayWithSize:vMAT_MakeSize(4,3) type:miSINGLE];
    Mat<float> Xv = matXv;
    Xv << 4,9,169,
    121,100,64,
    49,36,144,
    196,225,1;
    STAssertEqualObjects(matX, matXv, @"Ensure equal arrays");
}

-(void) testVMatLoadedSavedFileCorrectly
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"cluster-normaldata-10x3-13" withExtension:@"mat"];
    NSError *error = nil;
    NSDictionary * workspace = vMAT_load(url, @[ @"X",@"Zv",@"Wv",@"VCv",@"VMv"], &error);
    NSLog(@"workspace = %@",workspace);
    vMAT_Array *X = [workspace variable:@"X"].matrix;
    vMAT_Array *Zv = [workspace variable:@"Zv"].matrix;
    vMAT_Array *Wv = [workspace variable:@"Wv"].matrix;
    vMAT_Array *VCv = [workspace variable:@"VCv"].matrix;
    vMAT_Array *VMv = [workspace variable:@"VMv"].matrix;
    
    //Check if we loaded the matrices properly.
    STAssertNotNil(X, @"X is not supposed to be nil.");
    STAssertNotNil(Zv, @"Zv is not supposed to be nil.");
    STAssertNotNil(Wv, @"Wv is not supposed to be nil.");
    STAssertNotNil(VCv, @"VCv is not supposed to be nil.");
    STAssertNotNil(VMv, @"VMv is not supposed to be nil.");
    //Peek at the contents of the Matricies
    NSLog(@"X = %@",X.dump);
    NSLog(@"Zv = %@",Zv.dump);
    NSLog(@"Wv = %@",Wv.dump);
    NSLog(@"VCv = %@",VCv.dump);
    NSLog(@"VMv = %@",VMv.dump);
    //Convert the Matrix To a obj-c usable form.
    Mat<float> XMat = X;
    Matrix<float,Eigen::Dynamic,Eigen::Dynamic> XMatMat = XMat;
    //Run a simple operation on it.
    XMatMat.cwiseProduct(XMatMat);
    //Convert it back to vMat.
    vMAT_Array *Xsquared = vMAT_cast(XMatMat);
    vMAT_MATv5Variable *var = [vMAT_MATv5Variable variableWithArray:Xsquared arrayFlags:0 name:@"Xsquared" ];
    //vMAT_MATv5NumericArray *array = [[vMAT_MATv5NumericArray alloc] init];
    NSMutableDictionary *XsquaredWorkspaceEditor = [[NSMutableDictionary alloc] init];
    [XsquaredWorkspaceEditor  setValue:var forKey:@"Xsquared"];
    NSURL *urlOut = [NSURL fileURLWithPath:@"Xsquare.mat"];
    NSLog(@"URL = %@",urlOut);
    vMAT_save(urlOut, XsquaredWorkspaceEditor, &error);
    NSDictionary *workspaceReload = vMAT_load(urlOut, @[@"Xsquared"], &error);
    vMAT_Array *reload = [workspaceReload variable:@"Xsquared"].matrix;
    STAssertEqualObjects(Xsquared  , reload, @"Xsquared might not be saved correctly");
    
    
}
@end
