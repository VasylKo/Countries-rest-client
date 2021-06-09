//
//  CountryInfoViewModel.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 11.06.2021.
//

import RxSwift
import RxCocoa
import Foundation

protocol CountryInfoViewModel {
    var title: String{ get }
    var loading: Driver<Bool> { get }
    var countryInfoObservable: Driver<CountryInfo> { get }

    func fetchCountryInfo()
}

class RestCountryInfoViewModel: CountryInfoViewModel {
    var title: String {
        country.name
    }

    var loading: Driver<Bool> {
        activityIndicator.asDriver()
    }
    var countryInfoObservable: Driver<CountryInfo> {
        countryInfoBehaviorRelay.compactMap { $0 }.asDriverOnErrorJustComplete()
    }

    private let countriesService: CountriesService = ServiceLayer.shared.countriesService
    private let logger: LoggerService = ServiceLayer.shared.loggerService
    private let alertPresenter: AlertPresenter = ServiceLayer.shared.alertPresenter

    private let countryInfoBehaviorRelay: BehaviorRelay<CountryInfo?> = .init(value: nil)
    private let activityIndicator: ActivityIndicator = .init()
    private let disposeBag: DisposeBag = .init()

    private let country: Country

    init(country: Country) {
        self.country = country
    }

    func fetchCountryInfo() {
        countriesService
            .country(name: country.name)
            .delay(.seconds(Constatns.loadingDataDelaySeconds), scheduler: MainScheduler.instance)
            .trackActivity(activityIndicator)
            .subscribe(
                onNext: { infos in
                    self.logger.debug(from: self, message: "Success")
                    self.countryInfoBehaviorRelay.accept(infos.first)
                },
                onError: { error in
                    self.logger.error(from: self, error: error)
                    self.processError(error)
                }
            )
            .disposed(by: disposeBag)
    }

    private func processError(_ error: Error) {
        DispatchQueue.main.async {
            self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
        }
    }
}
