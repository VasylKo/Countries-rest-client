//
//  PrintLoggerService.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

class PrintLoggerService: LoggerService {
    private let loggerLevel: LoggerLevel

    init(loggerLevel: LoggerLevel) {
        self.loggerLevel = loggerLevel
    }

    func log(level: LoggerLevel, message: String, object: Any, function: String) {
        guard level.rawValue >= loggerLevel.rawValue else { return }

        print("\(String(describing: type(of: object))). \(function). \(message)")
    }
}
