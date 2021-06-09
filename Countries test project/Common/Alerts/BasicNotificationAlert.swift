//
//  BasicNotificationAlert.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit

class BasicNotificationAlert: NotificationAlert {
    var action: (() -> Void)?
    var hideAction: (() -> Void)?
    var important: Bool {
        false
    }
    var unique: Bool {
        false
    }

    private(set) var view: UIView = UIView()
    private(set) var label: UILabel = UILabel()
    var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    private var swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()

    var textColor: UIColor {
        .white
    }

    private var attributedText: NSAttributedString?

    init(title: String? = nil, text: String, action: (() -> Void)? = nil) {
        self.action = action

        setupUI()
        setupContent(title: title, text: text)
        updateContent()
    }

    private var centered: NSParagraphStyle {
        let result = NSMutableParagraphStyle()
        result.alignment = .center
        return result
    }

    private func setupContent(title: String? = nil, text: String) {
        let attributedText = NSMutableAttributedString()

        if let title = title {
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .paragraphStyle: centered,
                .foregroundColor: textColor
            ]
            let attributedTitle = NSAttributedString(string: "\(title)\n", attributes: titleAttributes)
            attributedText.append(attributedTitle)
        }

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: centered,
            .foregroundColor: textColor
        ]
        let attributedSecondaryText = NSAttributedString(string: text, attributes: textAttributes)
        attributedText.append(attributedSecondaryText)

        self.attributedText = attributedText
    }

    func setupUI() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        view.addSubview(label)

        let line = HairLineView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.bottomRight = true
        view.addSubview(line)

        let margin: CGFloat = 18

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: margin).with(priority: .required - 1),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin).with(priority: .required - 1),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).with(priority: .required - 1),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).with(priority: .required - 1),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tapGesture.addTarget(self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)

        swipeGesture.direction = .up
        swipeGesture.addTarget(self, action: #selector(swipe))
        view.addGestureRecognizer(swipeGesture)
    }

    @objc private func tap() {
        hideAction?()
        action?()
    }

    @objc private func swipe() {
        hideAction?()
    }

    private func updateContent() {
        label.attributedText = attributedText
    }
}

extension NSLayoutConstraint {
    public func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
