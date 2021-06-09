//
//  ServiceLayer.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

class ServiceLayer {
    static let shared = ServiceLayer()

    let countriesService: CountriesService = RestCountriesService()
    let loggerService: LoggerService = PrintLoggerService(loggerLevel: .verbose)
    let alertPresenter: AlertPresenter = WindowAlertPresenter()
    let reachabilityService: ReachabilityService = try! DefaultReachabilityService()
}
