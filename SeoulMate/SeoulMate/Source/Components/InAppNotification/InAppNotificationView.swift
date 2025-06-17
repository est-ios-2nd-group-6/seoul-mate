import UIKit

class InAppNotificationView: UIView {

    let iconImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "checkmark.fill")

        return imageView
    }()

    let messageLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor.systemBlue
        layer.cornerRadius = 8
        clipsToBounds = true
        addShadow()

        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [iconImageView, messageLabel])

            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .horizontal
            stack.alignment = .center
            stack.spacing = 8

            return stack
        }()

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }

    func show(
        message: String,
        in viewController: UIViewController,
        duration: TimeInterval = 1.0,
        backgroundColor: UIColor = .main,
        iconName: String? = "checkmark.fill",
        completion: (() -> Void)? = nil
    ) {
        self.messageLabel.text = message
        self.backgroundColor = backgroundColor

        if let iconName = iconName {
            iconImageView.image = UIImage(systemName: iconName)
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }

        viewController.view.addSubview(self)

        let safeAreaTopInset = viewController.view.safeAreaInsets.top
        let preferredHeight: CGFloat = 50.0 // 원하는 고정 높이

        let initialY = safeAreaTopInset - preferredHeight - 20
        self.frame = CGRect(x: 20, y: initialY, width: viewController.view.bounds.width - 40, height: preferredHeight)

        let finalY = safeAreaTopInset + 10 // 안전 영역 하단에서 10pt 아래

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.frame.origin.y = finalY
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseIn], animations: {
                self.frame.origin.y = initialY
            }) { _ in
                self.removeFromSuperview()
                completion?()
            }
        }
    }
}
