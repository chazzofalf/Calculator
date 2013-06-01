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
@class SaveVars;
@interface SaveVars : NSObject
{
    @protected
    vMAT_Array *_x;
    @protected
    vMAT_Array *_y;
    @protected
    vMAT_Array *_z;
    @protected
    vMAT_Array *_zv;
    @protected
    vMAT_Array *_wv;
    @protected
    vMAT_Array *_zw;
    @protected
    vMAT_Array *_vcv;
    @protected
    vMAT_Array *_vmv;
    @protected
    NSError *_error;
    @protected
    NSException *_exception;
}
@property (readwrite,nonatomic,retain) vMAT_Array *x;
@property (readwrite,nonatomic,retain) vMAT_Array *y;
@property (readwrite,nonatomic,retain) vMAT_Array *z;
@property (readwrite,nonatomic,retain) vMAT_Array *zv;
@property (readwrite,nonatomic,retain) vMAT_Array *wv;
@property (readwrite,nonatomic,retain) vMAT_Array *zw;
@property (readwrite,nonatomic,retain) vMAT_Array *vcv;
@property (readwrite,nonatomic,retain) vMAT_Array *vmv;
@property (readonly,nonatomic,retain) NSError *error;
@property (readonly,nonatomic,retain) NSException *exception;
-(void) save;
@end
@implementation SaveVars
@synthesize x = _x;
@synthesize y = _y;
@synthesize z = _z;
@synthesize zv = _zv;
@synthesize wv = _wv;
@synthesize zw = _zw;
@synthesize vcv = _vcv;
@synthesize vmv = _vmv;
@synthesize error = _error;
@synthesize exception = _exception;
-(void) save
{
    NSArray *objects = @[_x,_y,_z,_zv,_wv,_zw,_vcv,_vmv];
    NSArray *names = @[@"X",@"Y",@"Z",@"Zv",@"Wv",@"Zw",@"Vcv",@"Vmv"];
    NSMutableDictionary *workspace = [[NSMutableDictionary alloc] init];
    @try {
        for (int i=0;i<[names count];i++)
        {
            vMAT_Array *currentValue = [objects objectAtIndex:i];
            NSString *name = [names objectAtIndex:i];
            vMAT_MATv5Variable *var = [vMAT_MATv5Variable variableWithArray:currentValue arrayFlags:0 name:name];
            [workspace setObject:var forKey:name];
        }
        NSURL *outputURL = [NSURL fileURLWithPath:@"output.mat"];
        NSError *error = nil;
        vMAT_save(outputURL, workspace, &error);
        _error = error;
    }
    @catch (NSException *exception) {
        _exception = exception;
    }
    @finally {
        
    }
    
}
@end
@class LoadedVars;
@interface LoadedVars : NSObject
{
@protected
    vMAT_Array *_x;
@protected
    vMAT_Array *_zv;
@protected
    vMAT_Array *_wv;
@protected
    vMAT_Array *_vcv;
@protected
    vMAT_Array *_vmv;
@protected
    NSError *_error;
}
-(id) initByLoading;
@property (readonly,nonatomic,retain) vMAT_Array *x;
@property (readonly,nonatomic,retain) vMAT_Array *zv;
@property (readonly,nonatomic,retain) vMAT_Array *wv;
@property (readonly,nonatomic,retain) vMAT_Array *vcv;
@property (readonly,nonatomic,retain) vMAT_Array *vmv;
@property (readonly,nonatomic,retain) NSError *error;
@end
@implementation LoadedVars
@synthesize x = _x;
@synthesize zv = _zv;
@synthesize wv = _wv;
@synthesize vcv = _vcv;
@synthesize vmv = _vmv;
@synthesize error = _error;
-(id) initByLoading
{
    
    if (self != nil)
    {
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"cluster-normaldata-10x3-13" withExtension:@"mat"];
        NSError *error = nil;
        NSDictionary * workspace = vMAT_load(url, @[ @"X",@"Zv",@"Wv",@"VCv",@"VMv"], &error);
        _error = error;
        if (_error == nil)
        {
            _x = [workspace variable:@"X"].matrix;
            _zv = [workspace variable:@"Zv"].matrix;
            _wv = [workspace variable:@"Wv"].matrix;
            _vcv = [workspace variable:@"VCv"].matrix;
            _vmv = [workspace variable:@"VMv"].matrix;
        }
        
        
    }
    return self;
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
    NSURL *urlOut = [NSURL fileURLWithPath:@"Xsquared.mat"];
    NSLog(@"URL = %@",urlOut);
    vMAT_save(urlOut, XsquaredWorkspaceEditor, &error);
    NSDictionary *workspaceReload = vMAT_load(urlOut, @[@"Xsquared"], &error);
    vMAT_Array *reload = [workspaceReload variable:@"Xsquared"].matrix;
    
    
    STAssertEqualObjects(Xsquared  , reload, @"Xsquared might not be saved correctly");
    vMAT_Array *transposed = vMAT_mtrans(X);
    var = [vMAT_MATv5Variable variableWithArray:transposed arrayFlags:0 name:@"Xtrans"];
    urlOut = [NSURL fileURLWithPath:@"Xtrans.mat"];
    XsquaredWorkspaceEditor = [[NSMutableDictionary alloc] init];
    [XsquaredWorkspaceEditor setValue:var forKey:@"Xtrans"];
    vMAT_save(urlOut,XsquaredWorkspaceEditor,&error);
    vMAT_Array * matXv = [vMAT_Array arrayWithSize:vMAT_MakeSize(4,3) type:miSINGLE];
    Mat<float> Xv = matXv;
    Xv << 4,9,169,
    121,100,64,
    49,36,144,
    196,225,1;
    var = [vMAT_MATv5Variable variableWithArray:matXv arrayFlags:0 name:@"Xv"];
    urlOut = [NSURL fileURLWithPath:@"Xv.mat"];
    XsquaredWorkspaceEditor = [[NSMutableDictionary alloc] init];
    [XsquaredWorkspaceEditor setValue:var forKey:@"Xv"];
    vMAT_save(urlOut,XsquaredWorkspaceEditor,&error);

    
    NSLog(@"X Transposed = %@",transposed.dump);
    
    
}
-(NSDictionary *)loadAll
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"cluster-normaldata-10x3-13" withExtension:@"mat"];
    NSError *error = nil;
    NSDictionary * workspace = vMAT_load(url, @[ @"X",@"Zv",@"Wv",@"VCv",@"VMv"], &error);
    return workspace;
}
-(vMAT_Array *)transpose: (vMAT_Array *)input
{
    Mat<double> inputSim = input;
    MatrixXd inputSimMat = inputSim;
    MatrixXd inputSimTransMat = inputSimMat.transpose();
    vMAT_Array *trans = vMAT_cast(inputSimTransMat);
    return trans;
}
-(void) testVMatCluster
{
    LoadedVars *vars = [[LoadedVars alloc] initByLoading];
    SaveVars *saveVars = [[SaveVars alloc] init];
    saveVars.x = vars.x;
    NSLog(@"X = %@",saveVars.x.dump);
    vMAT_Array *x_ = [self transpose:saveVars.x];
    NSLog(@"X' = %@",x_.dump);
    saveVars.y = vMAT_pdist(x_);
    NSLog(@"Y = %@",saveVars.y.dump);
}
@end

