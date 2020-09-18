import XCTest

import LibraryTests

var tests = [XCTestCaseEntry]()
tests += LibraryTests.allTests()
XCTMain(tests)
