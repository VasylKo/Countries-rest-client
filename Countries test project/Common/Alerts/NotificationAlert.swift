//
//  NotificationAlert.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit

class NotificationAlertIdentity: Equatable {
    var id: String

    init(id: String) {
        self.id = id
    }

    static func == (lhs: NotificationAlertIdentity, rhs: NotificationAlertIdentity) -> Bool {
        lhs.id == rhs.id
    }
}

protocol NotificationAlert: AnyObject {
    var unique: Bool { get }
    var view: UIView { get }
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var hideAction: (() -> Void)? { get set }
    var important: Bool { get }
}
