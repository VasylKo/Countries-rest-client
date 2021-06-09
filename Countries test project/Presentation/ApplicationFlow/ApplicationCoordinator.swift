//
//  ApplicationCoordinator.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit

class ApplicationCoordinator {
    let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    private let logger: LoggerService = ServiceLayer.shared.loggerService

    func start() {
        logger.debug(from: self)
        window.backgroundColor = .white
        window.makeKeyAndVisible()

        startCountriesFlow()
    }

    private func startCountriesFlow() {
        let navigationController = UINavigationController()
        setRootViewController(navigationController)
        let coordinator = CountriesCoordinator(navigationController: navigationController) { [weak self] finishResult in
            guard let self = self else { return }

            switch finishResult {
                case .success:
                    self.logger.debug(from: self, message: "Flow finished success")
                case .failure:
                    self.logger.debug(from: self, message: "Flow finished failure")
            }
        }
        coordinator.startFlow()
    }

    private func setRootViewController(_ rootViewController: UIViewController, completion: (() -> Void)? = nil) {
        guard rootViewController != window.rootViewController else {
            completion?()
            return()
        }

        if let snapshot = window.rootViewController?.view.snapshotView(afterScreenUpdates: true) {
            rootViewController.view.addSubview(snapshot)
            window.rootViewController = rootViewController
            UIView.transition(
                with: snapshot,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: {
                    snapshot.layer.opacity = 0
                },
                completion: { _ in
                    snapshot.removeFromSuperview()
                    completion?()
                }
            )
        } else {
            window.rootViewController = rootViewController
            completion?()
        }
    }
}
