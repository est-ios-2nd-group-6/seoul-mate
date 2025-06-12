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
    
    var tags: [Tag] = []
    var tagButtons: [UIButton] = []

    private func initTagView() {
        tagButtons.forEach { $0.removeFromSuperview() }
        tagButtons = []

        let pickedNames = Set(CoreDataManager.shared.fetchSelectedTags().compactMap { $0.name })

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
        guard let title = sender.currentTitle,
              let tag = tags.first(where: { $0.name == title }) else { return }

        CoreDataManager.shared.toggle(tag: tag)

        let isSelected = tag.selected
        sender.isSelected = isSelected
        sender.backgroundColor = isSelected ? .main : .clear
        sender.setTitleColor(isSelected ? .white : .label, for: .normal)
        sender.layer.borderColor = isSelected ? UIColor.main.cgColor : UIColor.systemGray4.cgColor
        let hasPicked = CoreDataManager.shared.fetchSelectedTags().count > 0
        startButton.isEnabled = hasPicked
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        refreshButtonAppearances()
    }

    private var didSetUpTag = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didSetUpTag else { return }
        initTagView()
        didSetUpTag = true
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

        CoreDataManager.shared.firstFetchTag()
        tags = CoreDataManager.shared.fetchTags()

        startButton.isEnabled = false
    }
}
