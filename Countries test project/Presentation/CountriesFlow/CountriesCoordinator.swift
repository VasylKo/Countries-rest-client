//
//  CountriesCoordinator.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit

class CountriesCoordinator: BaseCoordinator {
    override func startFlow() {
        super.startFlow()

        showCountriesListScreen()
    }

    private func showCountriesListScreen() {
        logger.debug(from: self)
        let viewModel: CountriesViewModel = RestCountriesViewModel(output: .init(selectedCountry: {
            self.showCountryInfoScreen($0)
        }))
        let viewController: CountriesListViewController = .init(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showCountryInfoScreen(_ country: Country) {
        logger.debug(from: self)
        let viewModel: CountryInfoViewModel = RestCountryInfoViewModel(country: country)
        let viewController: CountryInfoViewController = CountryInfoViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
