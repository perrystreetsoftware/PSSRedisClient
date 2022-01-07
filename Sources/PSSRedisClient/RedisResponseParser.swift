//
//  RedisParseManager.swift
//  Husband Material
//
//

import Foundation

protocol RedisMessageReceivedDelegate: NSObjectProtocol {
    func redisMessageReceived(results: NSArray)
}

protocol RedisParserInterface: NSObjectProtocol {
    func parseLine(data: Data, parserStack: inout Array<RedisParserInterface>, results: inout Array<Any?>)
}

struct RedisStringParserClassConstants {
    static let separatorString = "\r\n"
    static let errorDomain = "com.perrystreetsoftware.PSSRedisError"
}

class RedisStringParser: NSObject, RedisParserInterface {
    var length: Int
    var value: String?
    private var isDebugLogEnabled: Bool

    init(length: Int, isDebugLogEnabled: Bool) {
        self.length = length;
        self.isDebugLogEnabled = isDebugLogEnabled
    }

    func parseLine(data: Data, parserStack: inout Array<RedisParserInterface>, results: inout Array<Any?>) {

        if let line : NSString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
            let separatorRange = line.range(of: RedisStringParserClassConstants.separatorString)

            if (separatorRange.location == NSNotFound) {
                return;
            }

            assert(self.length == separatorRange.location, "length mismatch");

            if (isDebugLogEnabled) {
                debugPrint("SOCKET: string \(line)")
            }

            results.append(line.substring(to: separatorRange.location));
        }
    }
}

class RedisGenericParser: NSObject, RedisParserInterface {
    private var isDebugLogEnabled: Bool
    
    init(isDebugLogEnabled: Bool) {
        self.isDebugLogEnabled = isDebugLogEnabled
    }
    
    func parseLine(data: Data, parserStack: inout Array<RedisParserInterface>, results: inout Array<Any?>) {

        guard let line: NSString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) else {
            return
        }

        let separatorRange = line.range(of: RedisStringParserClassConstants.separatorString)

        if (separatorRange.location == NSNotFound || separatorRange.location <= 0) {
            return
        }

        let restOfLineRange = NSMakeRange(1, separatorRange.location - 1)
        let restOfLine: String = line.substring(with: restOfLineRange)
        let firstCharacter: Character = Character(UnicodeScalar(line.character(at: 0))!)
        var debugPrefix: String? = nil
        
        switch (firstCharacter) {
        case "-".first!:
            debugPrefix = "-"

            let error =
                NSError(domain: RedisStringParserClassConstants.errorDomain,
                        code: -1,
                        userInfo: ["message": restOfLine]);
            results.append(error)
        case ":".first!:
            debugPrefix = "+"

            if let restOfLineInt = Int(restOfLine) {
                results.append(restOfLineInt)
            }
        case "+".first!:
            debugPrefix = "+"

            results.append(restOfLine);
        case "$".first!:
            debugPrefix = "$"

            if let length = Int(restOfLine) {
                if (length < 0) {
                    results.append(nil);
                } else {
                    let stringParser = RedisStringParser(length: length, isDebugLogEnabled: isDebugLogEnabled)
                    parserStack.append(stringParser)
                }
            }
        case "*".first!:
            debugPrefix = "*"

            if let length = Int(restOfLine) {
                for _ in 0..<length {
                    let genericParser = RedisGenericParser(isDebugLogEnabled: isDebugLogEnabled)
                    parserStack.append(genericParser);
                }
            }
            break;
        default:
            break;
        }
        
        if let debugPrefix = debugPrefix, isDebugLogEnabled == true {
            debugPrint("SOCKET: \(debugPrefix) -- \(restOfLine)")
        }
        
    }
}

class RedisResponseParser: NSObject {
    weak var delegate: RedisMessageReceivedDelegate?
    var parserStack: Array<RedisParserInterface>
    var results: Array<Any?>
    private var isDebugLogEnabled: Bool

    init(delegate: RedisMessageReceivedDelegate?, isDebugLogEnabled: Bool = true) {
        self.delegate = delegate
        self.isDebugLogEnabled = isDebugLogEnabled
        self.parserStack = Array<RedisParserInterface>()
        self.results = Array<Any?>()
    }

    func reset() {
        self.parserStack.removeAll()
        self.results.removeAll()
    }

    func parseLine(data: Data) {

        if (self.parserStack.count == 0) {
            self.parserStack.append(RedisGenericParser(isDebugLogEnabled: isDebugLogEnabled))
        }

        let parserInterface: RedisParserInterface = self.parserStack.last!
        self.parserStack.removeLast()

        parserInterface.parseLine(data: data, parserStack: &self.parserStack, results: &self.results)

        if (self.parserStack.count == 0) {
            let finalResults = Array<Any?>(self.results)
            
            self.delegate?.redisMessageReceived(results: finalResults as NSArray)
            self.results.removeAll()
        }
    }
}
