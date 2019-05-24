//
//  ParserTests.swift
//  PSSRedisClient_Tests
//
//  Created by Petr on 23/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import PSSRedisClient

class ParserTests: XCTestCase {

    private class ParserDelegateImp: NSObject, RedisMessageReceivedDelegate {

        var onMessageReceived: ((_ results: NSArray) -> Void)?

        func redisMessageReceived(results: NSArray) {
            onMessageReceived?(results)
        }
    }

    private func testResults(input: [Data], completion: @escaping (_ results: NSArray) -> Void) {

        let delegateImp = ParserDelegateImp()
        let parseManager =  RedisResponseParser(delegate: delegateImp)

        delegateImp.onMessageReceived = { (results) in
            completion(results)
        }

        input.forEach { (data) in
            parseManager.parseLine(data: data)
        }

    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseError() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["-Error message\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 1)
            XCTAssert(results.firstObject is Error)
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseSimpleString() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["+OK\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 1)
            XCTAssert(results.firstObject is String)
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseBulkString() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["$6\r\n".data(using: .utf8)!,
                            "foobar\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 1)
            XCTAssertEqual(results.firstObject as? String, "foobar")
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseEmptyBulkString() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["$0\r\n".data(using: .utf8)!,
                            "\r\n".data(using: .utf8)!]) { (results) in
                                XCTAssert(results.count == 1)
                                XCTAssertEqual(results.firstObject as? String, "")
                                resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseNullBulkString() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["$-1\r\n".data(using: .utf8)!]) { (results) in
                                XCTAssert(results.count == 1)
                                XCTAssert(results[0] is NSNull)
                                resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseEmptyArray() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["*0\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 0)
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseStringArray() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["*2\r\n".data(using: .utf8)!,
                            "$3\r\n".data(using: .utf8)!,
                            "foo\r\n".data(using: .utf8)!,
                            "$3\r\n".data(using: .utf8)!,
                            "bar\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 2)
            XCTAssertEqual(results[0] as? String, "foo")
            XCTAssertEqual(results[1] as? String, "bar")
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseIntArray() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["*3\r\n".data(using: .utf8)!,
                            ":1\r\n".data(using: .utf8)!,
                            ":2\r\n".data(using: .utf8)!,
                            ":3\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 3)
            XCTAssertEqual(results[0] as? Int, 1)
            XCTAssertEqual(results[1] as? Int, 2)
            XCTAssertEqual(results[2] as? Int, 3)
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseMixedArray() {

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["*5\r\n".data(using: .utf8)!,
                            ":1\r\n".data(using: .utf8)!,
                            ":2\r\n".data(using: .utf8)!,
                            ":3\r\n".data(using: .utf8)!,
                            ":4\r\n".data(using: .utf8)!,
                            "$6\r\n".data(using: .utf8)!,
                            "foobar\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 5)
            XCTAssertEqual(results[0] as? Int, 1)
            XCTAssertEqual(results[1] as? Int, 2)
            XCTAssertEqual(results[2] as? Int, 3)
            XCTAssertEqual(results[3] as? Int, 4)
            XCTAssertEqual(results[4] as? String, "foobar")
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseNullArray() {

        // FIXME: This should return nil for results array by the docs, but we don't currently support that.

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["*-1\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 0)
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseArrayOfArrays() {

        // this is wrong

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["*2\r\n".data(using: .utf8)!,
                            "*3\r\n".data(using: .utf8)!,
                            ":1\r\n".data(using: .utf8)!,
                            ":2\r\n".data(using: .utf8)!,
                            ":3\r\n".data(using: .utf8)!,
                            "*2\r\n".data(using: .utf8)!,
                            "+Foo\r\n".data(using: .utf8)!,
                            "+Foo\r\n".data(using: .utf8)!]) { (results) in
                                XCTAssert(results.count == 2)

                                resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

    func testParseArrayWithNulllElements() {

        // this is wrong

        let resultsExpectation = expectation(description: "results")

        testResults(input: ["*3\r\n".data(using: .utf8)!,
                            "$3\r\n".data(using: .utf8)!,
                            "foo\r\n".data(using: .utf8)!,
                            "$-1\r\n".data(using: .utf8)!,
                            "$3\r\n".data(using: .utf8)!,
                            "bar\r\n".data(using: .utf8)!]) { (results) in
            XCTAssert(results.count == 3)
            XCTAssertEqual(results[0] as? String, "foo")
            XCTAssert(results[1] is NSNull)
            XCTAssertEqual(results[2] as? String, "bar")
            resultsExpectation.fulfill()
        }

        wait(for: [resultsExpectation], timeout: 10)
    }

}
