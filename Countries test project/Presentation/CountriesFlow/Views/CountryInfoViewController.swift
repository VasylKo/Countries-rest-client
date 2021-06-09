//
//  CountryInfoViewController.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 11.06.2021.
//

import UIKit
import RxCocoa

class CountryInfoViewController: BaseViewController {
    private var viewModel: CountryInfoViewModel!
    private let scrollView: UIScrollView = UIScrollView()
    private let rootStackView: UIStackView = .init()
    private let refreshControl: UIRefreshControl = UIRefreshControl()

    convenience init(viewModel: CountryInfoViewModel) {
        self.init()

        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
        viewModel.fetchCountryInfo()
    }

    private func setupUI() {
        title = viewModel.title
        scrollView.refreshControl = refreshControl
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(rootStackView)
        rootStackView.translatesAutoresizingMaskIntoConstraints = false

        rootStackView.axis = .vertical
        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        rootStackView.alignment = .fill
        rootStackView.distribution = .fill
        rootStackView.spacing = 10

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            rootStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            rootStackView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.countryInfoObservable.asObservable()
            .bind { [unowned self] countryInfo in
                self.updateCountryInfo(countryInfo)
            }
            .disposed(by: disposeBag)

        viewModel.loading.drive(refreshControl.rx.isRefreshing).disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged).bind(onNext: { [unowned self] _ in
            self.logger.debug(from: self, message: "refresh data")
            self.viewModel.fetchCountryInfo()
        }).disposed(by: disposeBag)
    }

    private func updateCountryInfo(_ countryInfo: CountryInfo) {
        rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let currencies = countryInfo.currencies.map { "\($0.name) (\($0.code)) \($0.symbol)" }.joined(separator: "\n")
        let borders = countryInfo.borders.joined(separator: "\n")
        [
            ("Name:", countryInfo.name),
            ("Capital:", countryInfo.capital),
            ("Population:", "\(countryInfo.population)"),
            ("Borders:", borders),
            ("Currency:", currencies ),
        ].forEach { info in
            rootStackView.addArrangedSubview(infoView(title: info.0, text: info.1))
            rootStackView.addArrangedSubview(separatorView())
        }
    }

    private func infoView(title: String, text: String) -> UIView {
        let stack: UIStackView = .init()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .top
        stack.spacing = 10

        let titleLabel: UILabel = .init()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.text = title
        stack.addArrangedSubview(titleLabel)

        let textLabel: UILabel = .init()
        textLabel.textAlignment = .right
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.setContentHuggingPriority(.required - 1, for: .horizontal)
        textLabel.numberOfLines = 0
        textLabel.text = text
        stack.addArrangedSubview(textLabel)

        return stack
    }

    private func separatorView() -> HairLineView {
        let sepaartor = HairLineView()
        sepaartor.lineColor = .lightGray
        sepaartor.translatesAutoresizingMaskIntoConstraints = false
        sepaartor.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return sepaartor
    }
}
