//
//  NLAssertEqualOptional.swift
//  NLAssertEqualOptionalExample
//
//  Created by Nikola Lajic on 10/3/14.
//  Copyright (c) 2014 codecentric. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    func NLAssertEqualOptional<T : Equatable>(_ expression1: @autoclosure () -> T?, _ expression2: @autoclosure () -> T, _ message: String? = nil, file: String = #file, line: UInt = #line) {
        var m = "NLAssertEqualOptional failed - "
        if let e = expression1() {
            let e2 = expression2()
            if e != e2 {
                if let message = message {
                    m += message
                }
                else {
                    m += "Optional (\(e)) is not equal to (\(e2))"
                }
                self.recordFailure(withDescription: m, inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailure(withDescription: m + "Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }

    func NLAssertEqualOptional<T : Equatable>(_ expression1: @autoclosure () -> [T]?, _ expression2: @autoclosure () -> [T], _ message: String? = nil, file: String = #file, line: UInt = #line) {
        var m = "NLAssertEqualOptional failed - "
        if let e = expression1() {
            let e2 = expression2()
            if e != e2 {
                if let message = message {
                    m += message
                }
                else {
                    m += "Optional (\(e)) is not equal to (\(e2))"
                }
                self.recordFailure(withDescription: m, inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailure(withDescription: m + "Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }

    func NLAssertEqualOptional<T, U : Equatable>(_ expression1: @autoclosure () -> [T : U]?,_ expression2: @autoclosure () -> [T : U], _ message: String? = nil, file: String = #file, line: UInt = #line) {
        var m = "NLAssertEqualOptional failed - "
        if let e = expression1() {
            let e2 = expression2()
            if e != e2 {
                if let message = message {
                    m += message
                }
                else {
                    m += "Optional (\(e)) is not equal to (\(e2))"
                }
                self.recordFailure(withDescription: m, inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailure(withDescription: m + "Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }
}
