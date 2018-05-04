import Foundation
import XCTest

@testable import CSVEncoder

class CSVEncoderTests: XCTestCase {
  
  static var allTests = [
    ("testEncoder", testRowEncoder),
    ]
  
  struct Row: Encodable {
    let time = Date(timeIntervalSince1970: 0)
    let string = "some string"
    let number = 512.34
    let optional: String? = nil
  }
  
  func testRowEncoder() throws {
    let encoder = CSVEncoder()
    
    let headers = ["time", "string", "number", "optional"]
    let rows = [Row(),
                Row()]
    
    try! encoder.encode(headers: headers)
    let data = try! encoder.encode(rows: rows)
    let string = String(data: data, encoding: .utf8)

    let expectedString = """
time,string,number,optional
1970-01-01 00:00:00.000,some string,512.34,
1970-01-01 00:00:00.000,some string,512.34,

"""

    XCTAssertEqual(string, expectedString)
  }
  
}
