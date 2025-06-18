import UIKit

/// 앱 상단에 일시적으로 나타나는 알림 배너 UI 컴포넌트.
///
/// `show(message:in:...)` 메서드를 통해 뷰 컨트롤러에 쉽게 추가하고, 일정 시간 후 자동으로 사라지는 애니메이션을 포함.
class InAppNotificationView: UIView {

    // MARK: - UI Components

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
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

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    /// 뷰의 기본 UI 및 레이아웃 설정.
    private func setupView() {
        backgroundColor = UIColor.systemBlue
        layer.cornerRadius = 8
        clipsToBounds = true
        addShadow()

        // Stack View에 추가
        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .horizontal
            stack.alignment = .center
            stack.spacing = 8
            return stack
        }()

        addSubview(stackView)

        // 제약 조건 추가
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

    /// 뷰에 그림자 효과를 추가.
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }

    // MARK: - Public Methods

    /// 지정된 뷰 컨트롤러의 상단에 알림 뷰를 애니메이션과 함께 표시.
    ///
    /// - Parameters:
    ///   - message: 알림 뷰에 표시할 텍스트.
    ///   - viewController: 알림 뷰가 추가될 부모 뷰 컨트롤러.
    ///   - duration: 알림 뷰가 화면에 머무르는 시간. 기본값은 1.0초.
    ///   - backgroundColor: 알림 뷰의 배경색.
    ///   - iconName: 메시지 왼쪽에 표시될 SF Symbol 아이콘 이름. `nil`일 경우 아이콘 숨김.
    ///   - completion: 알림 뷰가 사라진 후 실행될 클로저.
    func show(
        message: String,
        in viewController: UIViewController,
        duration: TimeInterval = 1.0,
        backgroundColor: UIColor = .main,
        iconName: String? = "checkmark.circle.fill",
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
        let preferredHeight: CGFloat = 50.0

        // 초기 위치: 화면 상단 밖
        let initialY = safeAreaTopInset - preferredHeight - 20
        self.frame = CGRect(x: 20, y: initialY, width: viewController.view.bounds.width - 40, height: preferredHeight)

        // 최종 위치: 안전 영역 상단에서 10pt 아래
        let finalY = safeAreaTopInset + 10

        // 나타나는 애니메이션
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.frame.origin.y = finalY
        }) { _ in
            // 사라지는 애니메이션
            UIView.animate(withDuration: 0.5, delay: duration, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseIn], animations: {
                self.frame.origin.y = initialY
            }) { _ in
                self.removeFromSuperview()
                completion?()
            }
        }
    }
}
