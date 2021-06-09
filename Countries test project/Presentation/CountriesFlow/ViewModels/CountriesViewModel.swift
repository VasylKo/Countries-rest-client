//
//  CountriesViewModel.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import RxSwift
import RxCocoa
import Foundation

protocol CountriesViewModel {
    var loading: Driver<Bool> { get }
    var countriesObservable: Driver<[Country]> { get }

    func fetchCountries()
    func selectedCountry(_ country: Country)
}

class RestCountriesViewModel: CountriesViewModel {
    private(set) lazy var loading: Driver<Bool> = activityIndicator.asDriver()
    private(set) lazy var countriesObservable: Driver<[Country]> = self.countriesBehaviorRelay.asDriver()

    struct Output {
        var selectedCountry: (Country) -> Void
    }

    private var output: Output

    init(output: Output) {
        self.output = output
    }

    private let countriesService: CountriesService = ServiceLayer.shared.countriesService
    private let logger: LoggerService = ServiceLayer.shared.loggerService
    private let alertPresenter: AlertPresenter = ServiceLayer.shared.alertPresenter

    private let countriesBehaviorRelay: BehaviorRelay<[Country]> = .init(value: [])
    private let activityIndicator: ActivityIndicator = .init()
    private let disposeBag: DisposeBag = .init()

    func fetchCountries() {
        countriesService
            .allContries()
            .delay(.seconds(Constatns.loadingDataDelaySeconds), scheduler: MainScheduler.instance)
            .trackActivity(activityIndicator)
            .subscribe(
                onNext: { contries in
                    self.logger.debug(from: self, message: "Success")
                    self.countriesBehaviorRelay.accept(contries)
                },
                onError: { error in
                    self.countriesBehaviorRelay.accept([])
                    self.logger.error(from: self, error: error)
                    self.processError(error)
                }
            )
            .disposed(by: disposeBag)
    }

    func selectedCountry(_ country: Country) {
        output.selectedCountry(country)
    }

    private func processError(_ error: Error) {
        DispatchQueue.main.async {
            self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
        }
    }
}
