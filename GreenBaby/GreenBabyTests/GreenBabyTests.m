//
//  GreenBabyTests.m
//  GreenBabyTests
//
//  Created by LiXiangCheng on 15/7/28.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface GreenBabyTests : XCTestCase

@end

@implementation GreenBabyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

//- (void)testFetchRequestWithMockedManagedObjectContext
//{
//    MockNSManagedObjectContext *mockContext = [[MockNSManagedObjectContext alloc] initWithConcurrencyType:0x00];
//    
//    let mockContext = MockNSManagedObjectContext()
//    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
//    let fetchRequest = NSFetchRequest(entityName: "User")
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email ENDSWITH[cd] apple.com"];
//    fetchRequest.predicate = NSPredicate(format: "email ENDSWITH[cd] %@", "apple.com")
//    fetchRequest.resultType = NSDictionaryResultType;
//    fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
//    var error: NSError?
//    NSError *error = nil;
//    NSArray *results = [mockContext executeFetchRequest:fetchRequest error:&error];
//    let results = mockContext.executeFetchRequest(fetchRequest, error: &error)
//    XCTAssertNil(error, @"error应该为nil");
//    XCTAssertEqual(results.count, 2, @"fetch request应该只返回一个结构");
//    NSDictionary * result = results[0];
//    XCTAssertEqual(result[@"name"], @"张三", @"name应该是张三");
//    NSLog(@"email : %@",result[@"email"]);
//    XCTAssertEqual(result[@"email"], @"zhangsaan@apple.com", @"email应该是zhangsan@apple.com");
//}

@end
