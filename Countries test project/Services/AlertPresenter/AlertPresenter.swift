//
//  AlertPresenter.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

/// Alert presenter protocol.
protocol AlertPresenter {
    /// Shows an alert.
    /// - parameter alert: alert to show
    /// - returns: identity that can be used to hide alert
    @discardableResult
    func show(alert: NotificationAlert) -> NotificationAlertIdentity

    /// Hides an alert.
    /// - parameter id: notification alert identity that is returned when alert is being shown
    func hide(id: NotificationAlertIdentity)

    /// Hides all alerts.
    func hideAll()
}
