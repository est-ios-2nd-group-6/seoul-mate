//
//  CustomAlertController.swift
//  SeoulMate
//
//  Created by DEV on 6/11/25.
//

import UIKit

class CustomAlertController: UIViewController {

    let backgroundView = UIView()
    let messageLabel = UILabel()
    let confirmButton = UIButton()
    let cancelButton = UIButton()
    let stackView = UIStackView()
    weak var delegate: (any CustomAlertControllerDelegate)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        backgroundView.backgroundColor = .systemBackground
        backgroundView.layer.cornerRadius = 6
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        messageLabel.text = "최근 검색 기록을 \n모두 삭제하시겠습니까?"
        messageLabel.numberOfLines = 2
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(messageLabel)

        confirmButton.setTitle("삭제", for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        confirmButton.setTitleColor(.blue, for: .normal)
        confirmButton.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cancelButton.setTitleColor(.lightGray, for: .normal)
        cancelButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(confirmButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)

        NSLayoutConstraint.activate([
            backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 260),
            backgroundView.heightAnchor.constraint(equalToConstant: 120),

            messageLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),

            stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc func dismissAlert() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0
            self.view.backgroundColor = .clear
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    @objc func deleteItem() {
        dismiss(animated: true)
        self.delegate?.deleteRecentItem(self)
    }
}

protocol CustomAlertControllerDelegate: AnyObject {
    func deleteRecentItem(_ alert: CustomAlertController)
}
