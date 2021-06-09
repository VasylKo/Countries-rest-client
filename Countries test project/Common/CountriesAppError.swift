//
//  CountriesAppError.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

enum CountriesAppError: Error {
    case noInternetConnection
    case mappingError(message: String)
    case httpError(code: Int, message: String)
    case error(Error)
}

protocol Displayable {
    var displayValue: String { get }
    var debugDisplayValue: String { get }
}

extension CountriesAppError: Displayable {
    var displayValue: String {
        switch self {
            case .noInternetConnection:
                return "Интернет соединение отсутствует. Пожалуйста, попробуйте повторить запрос позже"
            case .mappingError:
                return "Произошла ошибка при работе с данными. Пожалуйста, попробуйте повторить запрос позже"
            case .httpError:
                return "При выполнении запроса произошла ошибка. Пожалуйста, попробуйте повторить запрос позже"
            case .error:
                return "Произошла неизветсная ошибка. Пожалуйста, попробуйте повторить запрос позже"
        }
    }

    var debugDisplayValue: String {
        switch self {
            case .noInternetConnection:
                return "Интернет соединение отсутствует."
            case .mappingError(let message):
                return "Mapping error \(message)"
            case .httpError(let code, let message):
                return "Internet error. Code: \(code), \(message)"
            case .error(let error):
                return error.localizedDescription
        }
    }
}
