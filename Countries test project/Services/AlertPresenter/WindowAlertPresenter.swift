//
//  WindowAlertPresenter.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit

class WindowAlertPresenter: AlertPresenter {
    var maximumAlerts: Int {
        get {
            controller.maximumAlerts
        }
        set {
            controller.maximumAlerts = newValue
        }
    }

    var showDuration: TimeInterval {
        get {
            controller.showDuration
        }
        set {
            controller.showDuration = newValue
        }
    }

    var animationDuration: TimeInterval {
        get {
            controller.animationDuration
        }
        set {
            controller.animationDuration = newValue
        }
    }

    private var controller: AlertPresenterViewController = AlertPresenterViewController()
    private lazy var window: AlertWindow = {
        let window = AlertWindow()
        window.rootViewController = self.controller
        window.onHitTest = { [unowned self] point, event in
            self.controller.hitTest(point, with: event)
        }
        return window
    }()

    init() {
        controller.onShow = { [weak self] in
            self?.window.isHidden = false
        }
        controller.onHide = { [weak self] in
            self?.window.isHidden = true
        }
    }

    @discardableResult
    func show(alert: NotificationAlert) -> NotificationAlertIdentity {
        controller.show(alert: alert)
    }

    func hide(id: NotificationAlertIdentity) {
        controller.hide(id: id)
    }

    func hideAll() {
        controller.hideAll()
    }
}

private class AlertWindow: UIWindow {
    var onHitTest: (_ point: CGPoint, _ event: UIEvent?) -> UIView? = { _, _ in nil }

    init() {
        super.init(frame: UIScreen.main.bounds)

        windowLevel = .statusBar - 1
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        onHitTest(point, event)
    }
}

private class AlertPresenterViewController: UIViewController {
    var maximumAlerts: Int = 3

    var onShow: (() -> Void)?
    var onHide: (() -> Void)?

    private var contentView: UIStackView = UIStackView()
    private var statusBarView: UIView = UIView()

    var showDuration: TimeInterval = 5
    var animationDuration: TimeInterval = 0.3
    var startStackViewIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true
        contentView.axis = .vertical
        contentView.distribution = .fill
        contentView.alignment = .fill

        let fakeView = UIView()
        fakeView.translatesAutoresizingMaskIntoConstraints = false
        fakeView.backgroundColor = .white
        contentView.addArrangedSubview(fakeView)

        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.backgroundColor = .white
        statusBarView.isHidden = true
        contentView.addArrangedSubview(statusBarView)

        startStackViewIndex = contentView.arrangedSubviews.count

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fakeView.heightAnchor.constraint(equalToConstant: 0),
            statusBarView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        view.layoutIfNeeded()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        alerts.first?.alert.preferredStatusBarStyle ?? .default
    }


    /// Tests whether controller should interact with the tap at this point.
    func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        contentView.hitTest(point, with: event)
    }

    // MARK: - Timer

    private func startTimer() -> Timer {
        let timer = Timer(timeInterval: showDuration, target: self, selector: #selector(onTimer), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .default)
        RunLoop.main.add(timer, forMode: .tracking)
        return timer
    }

    @objc private func onTimer() {
        hideFirstAlert()
    }

    // MARK: - Presentation

    private class AlertData {
        var id: NotificationAlertIdentity
        var alert: NotificationAlert
        var timer: Timer?

        init(id: NotificationAlertIdentity, alert: NotificationAlert, timer: Timer?) {
            self.id = id
            self.alert = alert
            self.timer = timer
        }

        func clear() {
            timer?.invalidate()
            alert.hideAction = nil
        }
    }

    private var alerts: [AlertData] = []

    func show(alert: NotificationAlert) -> NotificationAlertIdentity {
        let alertId: NotificationAlertIdentity = alert.unique
            ? NotificationAlertIdentity(id: String(describing: type(of: alert)))
            : NotificationAlertIdentity(id: UUID().uuidString)
        if alert.unique && alerts.contains(where: { $0.id == alertId }) {
            return alertId
        }

        if alerts.isEmpty {
            onShow?()
        }

        var importantAlerts = alerts.filter { $0.alert.important }
        var normalAlerts = alerts.filter { !$0.alert.important }

        var alertsForDismiss: Array<AlertData>.SubSequence = []
        if maximumAlerts > 0 && normalAlerts.count >= maximumAlerts {
            let dropCount = normalAlerts.count - maximumAlerts + 1
            alertsForDismiss = normalAlerts.prefix(upTo: dropCount)
            normalAlerts = Array(normalAlerts.dropFirst(dropCount))

            alertsForDismiss.forEach { $0.clear() }
        }

        let timer = !alert.important ? startTimer() : nil
        let alertData = AlertData(id: alertId, alert: alert, timer: timer)

        alert.view.isHidden = true

        if alert.important {
            importantAlerts.append(alertData)
            contentView.insertArrangedSubview(alert.view, at: startStackViewIndex + importantAlerts.count - 1)
        } else {
            normalAlerts.append(alertData)
            contentView.addArrangedSubview(alert.view)
        }

        alerts = importantAlerts + normalAlerts

        alert.hideAction = { [weak self, weak alertData] in
            alertData.map { self?.hide(alertData: $0) }
        }
        setNeedsStatusBarAppearanceUpdate()

        UIView.animate(withDuration: animationDuration,
            animations: {
                self.statusBarView.backgroundColor = self.alerts[0].alert.view.backgroundColor
                self.statusBarView.isHidden = false

                alertsForDismiss.forEach { $0.alert.view.isHidden = true }
                alert.view.isHidden = false
            },
            completion: { _ in
                alertsForDismiss.forEach { $0.alert.view.removeFromSuperview() }
            }
        )

        return alertData.id
    }

    func hide(id: NotificationAlertIdentity) {
        alerts.first { $0.id == id }.map(hide)
    }

    private func hide(alertData: AlertData) {
        alertData.clear()

        alerts = alerts.filter { $0 !== alertData }
        setNeedsStatusBarAppearanceUpdate()

        UIView.animate(
            withDuration: animationDuration,
            animations: {
                alertData.alert.view.isHidden = true

                if self.alerts.isEmpty {
                    self.statusBarView.isHidden = true
                    self.statusBarView.backgroundColor = .white
                } else {
                    self.statusBarView.backgroundColor = self.alerts[0].alert.view.backgroundColor
                }
            },
            completion: { _ in
                alertData.alert.view.removeFromSuperview()

                if self.alerts.isEmpty {
                    self.onHide?()
                }
            }
        )
    }

    private func hideFirstAlert() {
        guard let alertData = alerts.first else { return }

        hide(alertData: alertData)
    }

    func hideAll() {
        guard !alerts.isEmpty else { return }

        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.alerts.forEach { data in
                    data.alert.view.isHidden = true
                }

                self.statusBarView.isHidden = true
                self.statusBarView.backgroundColor = .white
            },
            completion: { _ in
                self.alerts.forEach { data in
                    data.alert.view.removeFromSuperview()
                    data.clear()
                }
                self.alerts = []
                self.onHide?()
            }
        )
    }
}
