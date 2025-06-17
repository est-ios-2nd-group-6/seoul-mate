//
//  OnboardingViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/5/25.
//

import UIKit

final class OnboardingViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var imageNames: [String] {
        let idiom = UIDevice.current.userInterfaceIdiom
        let isPortrait = view.bounds.height > view.bounds.width
        switch idiom {
        case .pad:
            return isPortrait
            ? ["ipad1", "ipad2", "ipad3", "ipad4"]
            : ["ipadLandScape1", "ipadLandScape2", "ipadLandScape3", "ipadLandScape4"]
        default:
            return ["iphone1", "iphone2", "iphone3", "iphone4"]
        }
    }

    private var hasSettupPage = false
    private var imageViews: [UIImageView] = []
    @IBOutlet weak var startButton: UIButton!
    
    private func setupPages() {
        imageViews = imageNames.map { name in
            let iv = UIImageView(image: UIImage(named: name))
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            return iv
        }
        configureScrollView()
    }

    private func configureScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let pageWidth = scrollView.bounds.width
        let pageHeight = scrollView.bounds.height

        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.delegate = self

        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(imageViews.count),
                                        height: pageHeight)

        for (index, iv) in imageViews.enumerated() {
            iv.frame = CGRect(x: pageWidth * CGFloat(index),
                              y: 0,
                              width: pageWidth,
                              height: pageHeight)
            scrollView.addSubview(iv)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        setupPages()
        if !hasSettupPage {
            setupPages()
            hasSettupPage = true
        }
    }

    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let x = CGFloat(sender.currentPage) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
        scrollView.contentInsetAdjustmentBehavior = .never
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
        let idx = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pageControl.currentPage = Int(idx)
    }
}
