
import Foundation
import SwiftyBeaver
import SalesforceSDKCore

/**
 * Logging Levels
 *MTXBlaine Rothrock
 * - version: 1.0
 */
enum LogLevel:Int {
    case verbose = 0, debug, info, warning, error, none
}

/**
 * Singleton for logging
 *
 * - author: MTX
 * - version: 1.0
 */
class Logger {
    
    // singleton
    static let shared = Logger()
    
    // constant log level
    private let logLevel:LogLevel = LogLevel(rawValue: 1)!
   
    
    /**
     private initializer -- singleton only
     */
    private init() {
        
        SFSDKLogger.sharedDefaultInstance().logLevel = .error
        //SFLogger.shared().logLevel = .error
        let console = ConsoleDestination()
        console.format = "$C$L ➡ $M$c"
        SwiftyBeaver.addDestination(console)
        
        
    }
    
    /** 
     primary log function
     
     - parameter level: log level
     - parameter msg: string log message
     - parameter fileName: (optional) file the messages occurred
     - parameter functionName: (optional) function the message occurred
     - parameter lineNUmber: (optional) line number the message occurred
     */
    func log(level: LogLevel, msg: Any, fileName:String = #file, functionName:String = #function, lineNumber:Int = #line) {
        
        let message = "\((fileName as NSString).lastPathComponent).\(functionName):\(lineNumber) \(msg)"
        
        switch level {
        case .verbose where level.rawValue >= self.logLevel.rawValue:
            SwiftyBeaver.verbose(message)
           
        case .debug where level.rawValue >= self.logLevel.rawValue:
            SwiftyBeaver.debug(message)
           
        case .info where level.rawValue >= self.logLevel.rawValue:
            SwiftyBeaver.info(message)
           
        case .warning where level.rawValue >= self.logLevel.rawValue:
            SwiftyBeaver.warning(message)
            
        case .error where level.rawValue >= self.logLevel.rawValue:
            SwiftyBeaver.error(message)
           
        default:
            break // do nothing
        }
    }

}
