//
//  ViewController.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 09.06.2021.
//

import UIKit
import RxCocoa

class CountriesListViewController: BaseViewController {
    private enum Constatns {
        static let cellIdentifier: String = "TableViewCell"
    }

    private var viewModel: CountriesViewModel!
    private let tableView: UITableView = UITableView()
    private let refreshControl: UIRefreshControl = UIRefreshControl()

    convenience init(viewModel: CountriesViewModel) {
        self.init()

        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
        viewModel.fetchCountries()
    }

    private func setupUI() {
        title = "Countries"
        tableView.refreshControl = refreshControl

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constatns.cellIdentifier)
    }

    private func setupBindings() {
        viewModel.countriesObservable.drive(tableView.rx.items(cellIdentifier: Constatns.cellIdentifier)) { (index, country, cell) in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = country.name
            configuration.secondaryText = "Population: \(country.population)"
            cell.contentConfiguration = configuration
            cell.accessoryType = .disclosureIndicator
        }
        .disposed(by: disposeBag)

        viewModel.loading.drive(refreshControl.rx.isRefreshing).disposed(by: disposeBag)

        tableView.rx.itemSelected.withLatestFrom(viewModel.countriesObservable) { [unowned self] indexPath, countries in
            self.tableView.deselectRow(at: indexPath, animated: true)
            return countries[indexPath.row]
        }.asObservable().bind { [unowned self] country in
            self.viewModel.selectedCountry(country)
        }.disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged).bind(onNext: { [unowned self] _ in
            self.logger.debug(from: self, message: "refresh data")
            self.viewModel.fetchCountries()
        }).disposed(by: disposeBag)
    }
}

