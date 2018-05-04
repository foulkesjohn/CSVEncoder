import Foundation

public class CSVEncoder: Encoder {
  
  public var codingPath: [CodingKey] = []
  public var userInfo: [CodingUserInfoKey : Any] = [:]
  
  private var data = Data()
  
  public init() {}
  
  @discardableResult public func encode(headers: [String]) throws -> Data {
    write(headers.joined(separator: ","))
    write("\n")
    return data
  }
  
  public func encode<T: Encodable>(rows: T) throws -> Data {
    try rows.encode(to: self)
    return data
  }
  
  fileprivate func write(_ string: String) {
    data.append(string.data(using: .utf8)!)
  }
  
  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return KeyedEncodingContainer(CSVKeyedEncodingContainer<Key>(encoder: self))
  }
  
  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    return CSVUnkeyedEncodingContainer(encoder: self)
  }
  
  public func singleValueContainer() -> SingleValueEncodingContainer {
    return self as! SingleValueEncodingContainer
  }
  
  private struct CSVKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    var codingPath: [CodingKey] = []
    
    private let encoder: CSVEncoder
    
    fileprivate var formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.sss"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      return formatter
    }()
    
    public init(encoder: CSVEncoder) {
      self.encoder = encoder
    }
    
    mutating func encodeNil(forKey key: K) throws {}
    
    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
      if let date = value as? Date {
        encoder.write(formatter.string(from: date))
      } else if let string = value as? CustomStringConvertible {
        encoder.write(String(describing: string))
      }
      encoder.write(",")
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
      return encoder.container(keyedBy: keyType)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
      return encoder.unkeyedContainer()
    }
    
    mutating func superEncoder() -> Encoder {
      return encoder
    }
    
    mutating func superEncoder(forKey key: K) -> Encoder {
      return encoder
    }
    
  }
  
  private struct CSVUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    var codingPath: [CodingKey] = []
    var count: Int = 0
    
    private let encoder: CSVEncoder
    
    init(encoder: CSVEncoder) {
      self.encoder = encoder
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
      try value.encode(to: encoder)
      encoder.write("\n")
      count += 1
    }
    
    mutating func encodeNil() throws {
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
      return encoder.container(keyedBy: keyType)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
      return self
    }
    
    mutating func superEncoder() -> Encoder {
      return encoder
    }
    
  }
  
}
