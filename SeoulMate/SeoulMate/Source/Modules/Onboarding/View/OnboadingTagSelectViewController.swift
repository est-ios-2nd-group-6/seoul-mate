//
//  OnboadingTagSelectViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/11/25.
//

import UIKit

/// `OnboadingTagSelectViewController`는 온보딩 및 설정 화면에서
/// 사용자가 관심사 태그를 선택할 수 있도록 하는 뷰 컨트롤러입니다.
/// 선택된 태그에 따라 앱의 주요 콘텐츠 필터링을 수행합니다.
class OnboadingTagSelectViewController: UIViewController {

    // MARK: - 아울렛

    /// 태그 버튼을 조합하여 표시할 컨테이너 뷰
    @IBOutlet weak var tagListView: UIView!

    /// `tagListView` 높이를 동적으로 조절하기 위한 제약
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!

    /// 태그 선택 완료 후 다음 화면으로 이동하는 버튼
    @IBOutlet weak var startButton: UIButton!

    // MARK: - 속성

    /// 태그 비즈니스 로직 및 데이터 바인딩을 관리하는 ViewModel
    var viewModel = OnboardingTagModel()

    /// 태그 뷰 초기 셋업 여부를 추적하는 플래그
    private var didSetUpTag = false

    /// ViewModel에서 제공받은 태그 배열
    var tags: [Tag] = []

    /// 화면에 표시될 태그 버튼 배열
    var tagButtons: [UIButton] = []

    // MARK: - 액션

    /// 시작 버튼 탭 이벤트 핸들러
    /// - 설정 화면에서 호출된 경우: 이전 화면으로 팝
    /// - 온보딩 흐름에서 호출된 경우: 메인 탭바 컨트롤러로 전환
    @IBAction func startButtonTapped(_ sender: Any) {
        if viewModel.isFromSetting {
            navigationController?.popViewController(animated: true)
            return
        } else {
            // 메인 화면으로 전환
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let homeTabBarController = storyboard.instantiateInitialViewController() else { return }

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = homeTabBarController
                window.makeKeyAndVisible()
            }
        }
    }

    // MARK: - 라이프사이클

    /// 뷰 레이아웃이 업데이트된 후 호출됩니다.
    /// 태그 뷰를 한 번만 초기화하기 위해 `didSetUpTag` 플래그를 사용합니다.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 최초 레이아웃 시에만 태그 로드 및 뷰 초기화
        guard !didSetUpTag else { return }
        Task {
            await viewModel.loadTags()
            await initTagView()
            didSetUpTag = true
        }
    }

    /// 뷰가 사라지기 직전에 호출됩니다.
    /// 다음 화면 전환 시 네비게이션 바 가시성을 제어합니다.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    /// 뷰가 나타나기 직전에 호출됩니다.
    /// 네비게이션 바를 항상 표시하도록 설정합니다.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /// 뷰가 메모리에 로드된 직후 호출됩니다.
    /// 내비게이션 바 타이틀, 백버튼 표시 여부, 시작 버튼 타이틀 등을 초기화합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "관심있는 곳"

        // 설정 화면에서 호출된 경우 백버튼 숨김 처리
        navigationItem.hidesBackButton = !viewModel.isFromSetting

        // 시작 버튼 타이틀 설정
        if viewModel.isFromSetting {
            startButton.setTitle("설정 완료", for: .normal)
        } else {
            startButton.setTitle("여행 시작하기", for: .normal)
        }
        startButton.isEnabled = false
    }

    // MARK: - 태그 뷰 초기화

    /// ViewModel의 `tags`와 선택 상태 정보를 기반으로 태그 버튼을 생성하고 레이아웃 합니다.
    private func initTagView() async {
        // 기존 버튼 제거
        tagButtons.forEach { $0.removeFromSuperview() }
        tagButtons = []

        // ViewModel에서 선택된 태그 이름 집합 가져오기
        let pickedNames = await viewModel.selectedTagNames()

        // ViewModel이 로드한 모든 태그 순회하며 버튼 생성
        let tags = viewModel.tags
        tags.forEach { tag in
            let title = tag.name ?? ""
            let btn = createButton(with: title, selected: pickedNames.contains(title))
            btn.addTarget(self, action: #selector(touchTagButton(_:)), for: .touchUpInside)
            tagButtons.append(btn)
        }
        // 버튼 레이아웃 및 컨테이너 높이 조정
        attachTagButtons(at: tagListView, buttons: tagButtons)
        tagListViewHeight.constant = tagListView.subviews.map { $0.frame.maxY }.max() ?? tagListView.frame.height

        // 선택된 태그가 있으면 시작 버튼 활성화
        startButton.isEnabled = !pickedNames.isEmpty

        // 버튼 외관 갱신
        refreshButtonAppearances()
    }

    // MARK: - 버튼 상태 갱신

    /// 각 태그 버튼의 선택 상태에 따라 배경색, 글자색, 테두리색을 업데이트합니다.
    private func refreshButtonAppearances() {
        tagButtons.forEach { btn in
            let selectedState = btn.isSelected
            btn.backgroundColor = selectedState ? .main : .clear
            btn.setTitleColor(selectedState ? .white : .label, for: .normal)
            let borderColor = selectedState ? UIColor.main : UIColor.systemGray4
            btn.layer.borderColor = borderColor.cgColor
        }
    }

    // MARK: - 버튼 생성 및 레이아웃 헬퍼

    /// 태그 이름과 선택 상태에 따라 커스텀 UIButton을 생성합니다.
    private func createButton(with title: String, selected: Bool) -> UIButton {
        let baseFontSize: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            baseFontSize = 18
        } else {
            baseFontSize = 14
        }

        let font = UIFont.systemFont(ofSize: baseFontSize, weight: .medium)
        let scaledFont = UIFontMetrics.default.scaledFont(for: font)

        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = scaledFont
        btn.titleLabel?.adjustsFontForContentSizeCategory = true

        btn.setTitle(title, for: .normal)
        btn.isSelected = selected

        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 14

        btn.contentEdgeInsets = .init(top: 6.5, left: 15, bottom: 6.5, right: 15)
        btn.sizeToFit()
        btn.frame.size.height = max(btn.frame.height, 32)

        return btn
    }

    /// 주어진 뷰에 태그 버튼들을 FlowLayout 방식으로 배치합니다.
    private func attachTagButtons(at view: UIView, buttons: [UIButton]) {
        let marginX: CGFloat = 8
        let marginY: CGFloat = 8

        var x: CGFloat = 0
        var y: CGFloat = 0

        for (i, btn) in buttons.enumerated() {
            btn.frame.origin = CGPoint(x: x, y: y)
            view.addSubview(btn)

            let nextX = x + btn.frame.width + marginX
            // 다음 버튼이 줄 넘길 경우 줄 바꿈
            if i < buttons.count - 1,
               nextX + buttons[i + 1].frame.width > view.frame.width {
                x = 0
                y += btn.frame.height + marginY
            } else {
                x = nextX
            }
        }
    }

    // MARK: - 태그 선택 처리

    /// 태그 버튼 터치 이벤트 핸들러
    /// 선택 상태를 토글하고, 뷰 업데이트 및 시작 버튼 활성화 상태를 갱신합니다.
    @objc private func touchTagButton(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }

        Task {
            let isSelected = await viewModel.toggleSelection(for: title)
            sender.isSelected = isSelected

            // 버튼 외관 갱신
            sender.backgroundColor = isSelected ? .main : .clear
            sender.setTitleColor(isSelected ? .white : .label, for: .normal)
            sender.layer.borderColor = isSelected ? UIColor.main.cgColor : UIColor.systemGray4.cgColor

            // 시작 버튼 활성화 여부 갱신
            startButton.isEnabled = await viewModel.hasSelectedTags()
        }
    }

    // MARK: - 다크/라이트 모드 변경 대응

    /// 인터페이스 스타일 변경 시 버튼 외관을 갱신합니다.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        refreshButtonAppearances()
    }
}
