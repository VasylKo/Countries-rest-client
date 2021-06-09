//
//  LoggerService.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

enum LoggerLevel: Int {
    // Log all events
    case verbose = 0
    // Log errors only
    case error = 1
    // No logs
    case none = 2
}

protocol LoggerService {
    func log(level: LoggerLevel, message: String, object: Any, function: String)
}

extension LoggerService {
    func error(
        from object: Any,
        message: String = "",
        function: String = #function
    ) {
        log(level: .error, message: message, object: object, function: function)
    }

    func error(
        from object: Any,
        error: Error,
        function: String = #function
    ) {
        log(level: .error, message: (error as? Displayable)?.debugDisplayValue ?? error.localizedDescription, object: object, function: function)
    }

    func debug(
        from object: Any,
        message: String = "",
        function: String = #function
    ) {
        log(level: .verbose, message: message, object: object, function: function)
    }
}
