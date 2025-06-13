//
//  OnboadingTagSelectViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/11/25.
//

import UIKit

class OnboadingTagSelectViewController: UIViewController {

    @IBOutlet weak var tagListView: UIView!
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!
    @IBOutlet weak var startButton: UIButton!

    private var viewModel = OnboardingTagModel()
    private var didSetUpTag = false

    var tags: [Tag] = []
    var tagButtons: [UIButton] = []

    @IBAction func startButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeTabBarController = storyboard.instantiateInitialViewController() else { return }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = homeTabBarController
            window.makeKeyAndVisible()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didSetUpTag else { return }
        Task {
            await viewModel.loadTags()
            await initTagView()
            didSetUpTag = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "관심있는 곳"
        navigationItem.hidesBackButton = true

        startButton.isEnabled = false
    }
    
    private func initTagView() async {
        tagButtons.forEach { $0.removeFromSuperview() }
        tagButtons = []

        let pickedNames = await viewModel.selectedTagNames()

        let tags = viewModel.tags
        tags.forEach { tag in
            let title = tag.name ?? ""
            let btn = createButton(with: title, selected: pickedNames.contains(title))
            btn.addTarget(self, action: #selector(touchTagButton(_:)), for: .touchUpInside)
            tagButtons.append(btn)
        }

        attachTagButtons(at: tagListView, buttons: tagButtons)
        tagListViewHeight.constant = tagListView.subviews.map { $0.frame.maxY }.max() ?? tagListView.frame.height
        startButton.isEnabled = !pickedNames.isEmpty

        refreshButtonAppearances()
    }

    private func refreshButtonAppearances() {
        tagButtons.forEach { btn in
            let selectedState = btn.isSelected
            btn.backgroundColor = selectedState ? .main : .clear
            btn.setTitleColor(selectedState ? .white : .label, for: .normal)
            let borderColor = selectedState ? UIColor.main : UIColor.systemGray4
            btn.layer.borderColor = borderColor.cgColor
        }
    }

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

    private func attachTagButtons(at view: UIView, buttons: [UIButton]) {
        let marginX: CGFloat = 8
        let marginY: CGFloat = 8

        var x: CGFloat = 0
        var y: CGFloat = 0

        for (i, btn) in buttons.enumerated() {
            btn.frame.origin = CGPoint(x: x, y: y)
            view.addSubview(btn)

            let nextX = x + btn.frame.width + marginX
            if i < buttons.count - 1,
               nextX + buttons[i + 1].frame.width > view.frame.width {
                x = 0
                y += btn.frame.height + marginY
            } else {
                x = nextX
            }
        }
    }

    @objc private func touchTagButton(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }

        Task {
            let isSelected = await viewModel.toggleSelection(for: title)
            sender.isSelected = isSelected
            sender.backgroundColor = isSelected ? .main : .clear
            sender.setTitleColor(isSelected ? .white : .label, for: .normal)
            sender.layer.borderColor = isSelected ? UIColor.main.cgColor : UIColor.systemGray4.cgColor
            startButton.isEnabled = await viewModel.hasSelectedTags()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        refreshButtonAppearances()
    }
}
