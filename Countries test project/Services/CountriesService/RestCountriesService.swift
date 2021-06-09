//
//  RestCountriesService.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 09.06.2021.
//

import RxMoya
import Moya
import RxSwift

class RestCountriesService: CountriesService {
    private let provider = MoyaProvider<CountriesTarget>(plugins: [ NetworkLoggerPlugin(), CachePolicyPlugin() ])
    private lazy var reachabilityService: ReachabilityService = ServiceLayer.shared.reachabilityService

    func allContries() -> Observable<[Country]> {
        return provider.rx.request(.all)
            .filterSuccessfulStatusAndRedirectCodes()
            .map([Country].self)
            .asObservable()
            .catchError(mapErrorHandler())
            .retryWhen(retryErrorHandler)
    }

    func country(name: String) -> Observable<[CountryInfo]> {
        return provider.rx.request(.country(name))
            .filterSuccessfulStatusAndRedirectCodes()
            .map([CountryInfo].self)
            .asObservable()
            .catchError(mapErrorHandler())
            .retryWhen(retryErrorHandler)
    }

    /// Convert error to  CountriesAppError handler
    private func mapErrorHandler<T>() -> (Error) throws -> Observable<T> {
        let errorHandler: (Error) throws -> Observable<T> = { error in
            switch error {
                case let error as MoyaError:
                    switch error {
                        case .encodableMapping, .imageMapping, .jsonMapping, .objectMapping, .requestMapping, .stringMapping, .parameterEncoding:
                            throw CountriesAppError.mappingError(message: error.localizedDescription)
                        case .statusCode(let response):
                            throw CountriesAppError.httpError(code: response.statusCode, message: error.localizedDescription)
                        case .underlying(let error, _):
                            return self.reachabilityService.reachability
                                .map({ reachabilityStatus in
                                    if reachabilityStatus.reachable {
                                        throw CountriesAppError.error(error)
                                    } else {
                                        throw CountriesAppError.noInternetConnection
                                    }
                                })
                    }
                default:
                    throw CountriesAppError.error(error)
            }
        }

        return errorHandler
    }

    /// Retry error handling
    private let retryErrorHandler: (Observable<Error>) -> Observable<Int> = { error in
        error.enumerated().flatMap { attempt, error -> Observable<Int> in
            if attempt >= Constatns.maxRequestRetryCount - 1 {
                return Observable.error(error)
            } else if let casted = error as? CountriesAppError, case .noInternetConnection = casted {
                return Observable<Int>.timer(.seconds(Constatns.retryErrorAfterSeconds), scheduler: MainScheduler.instance).take(1)
            }

            return Observable.error(error)
        }
    }
}
