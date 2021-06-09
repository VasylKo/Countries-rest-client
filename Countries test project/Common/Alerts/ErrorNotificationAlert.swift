//
//  ErrorNotificationAlert.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit

class ErrorNotificationAlert: BasicNotificationAlert {
    override var textColor: UIColor {
        .black
    }

    init(error: Error, action: (() -> Void)? = nil) {
        let message = (error as? Displayable)?.displayValue ?? error.localizedDescription
        super.init(text: message, action: action)
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = .lightGray
    }
}
