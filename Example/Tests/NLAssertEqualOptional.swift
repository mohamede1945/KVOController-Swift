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
    func NLAssertEqualOptional<T : Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T, _ message: String? = nil, file: String = __FILE__, line: UInt = __LINE__) {
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
                self.recordFailureWithDescription(m, inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailureWithDescription(m + "Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }

    func NLAssertEqualOptional<T : Equatable>(@autoclosure expression1: () -> [T]?, @autoclosure _ expression2: () -> [T], _ message: String? = nil, file: String = __FILE__, line: UInt = __LINE__) {
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
                self.recordFailureWithDescription(m, inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailureWithDescription(m + "Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }

    func NLAssertEqualOptional<T, U : Equatable>(@autoclosure expression1: () -> [T : U]?,@autoclosure _ expression2: () -> [T : U], _ message: String? = nil, file: String = __FILE__, line: UInt = __LINE__) {
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
                self.recordFailureWithDescription(m, inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailureWithDescription(m + "Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }
}