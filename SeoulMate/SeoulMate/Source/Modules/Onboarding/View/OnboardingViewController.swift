//
//  OnboardingViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/5/25.
//

import UIKit

/// `OnboardingViewController`는 앱 첫 실행 시 온보딩 화면을 관리합니다.
/// 여러 페이지로 구성된 스크롤 뷰와 페이지 컨트롤을 연결하여 사용자가 좌우로 스와이프하며
/// 온보딩 이미지를 확인할 수 있도록 합니다.
final class OnboardingViewController: UIViewController {

    // MARK: - 아울렛

    /// 온보딩 이미지를 표시하는 스크롤 뷰
    @IBOutlet weak var scrollView: UIScrollView!

    /// 현재 페이지를 표시하는 페이지 컨트롤
    @IBOutlet weak var pageControl: UIPageControl!

    // MARK: - 속성

    /// 기기 유형(iPad/iPhone)과 화면 방향에 따라 사용할 이미지 이름 배열
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

    /// 페이지 구성이 완료되었는지 여부를 추적하는 플래그
    private var hasSettupPage = false

    /// 스크롤 뷰에 추가할 이미지 뷰 배열
    private var imageViews: [UIImageView] = []

    /// 온보딩 완료 후 시작 버튼
    @IBOutlet weak var startButton: UIButton!

    // MARK: - 페이지 구성

    /// `imageNames`에 정의된 이미지로 `imageViews`를 생성한 뒤 스크롤 뷰에 배치합니다.
    private func setupPages() {
        // 이미지 뷰 배열 생성
        imageViews = imageNames.map { name in
            let iv = UIImageView(image: UIImage(named: name))
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            return iv
        }
        configureScrollView()
    }

    /// 스크롤 뷰의 속성(페이징, 스크롤바 숨김 등)을 설정하고
    /// 생성된 `imageViews`를 프레임에 맞춰 추가합니다.
    private func configureScrollView() {
        // 기존 서브뷰 제거
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let pageWidth = scrollView.bounds.width
        let pageHeight = scrollView.bounds.height

        // 기존 서브뷰 제거
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.delegate = self

        // 전체 컨텐츠 크기 설정
        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(imageViews.count),
                                        height: pageHeight)

        // 각 페이지 위치에 이미지 뷰 추가
        for (index, iv) in imageViews.enumerated() {
            iv.frame = CGRect(x: pageWidth * CGFloat(index),
                              y: 0,
                              width: pageWidth,
                              height: pageHeight)
            scrollView.addSubview(iv)
        }
    }

    /// 뷰의 레이아웃이 업데이트된 후 호출됩니다.
    /// 스크롤 뷰의 프레임을 뷰와 맞추고, 페이지 설정 작업을 수행합니다.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 스크롤 뷰 크기를 전체 뷰 크기로 설정
        scrollView.frame = view.bounds

        // 페이지 구성이 한 번만 실행되도록 플래그 확인
        if !hasSettupPage {
            setupPages()
            hasSettupPage = true
        }
    }

    // MARK: - 페이지 컨트롤 이벤트

     /// 페이지 컨트롤 값이 변경될 때 호출됩니다.
     /// 스크롤 뷰의 오프셋을 해당 페이지로 이동시킵니다.
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let x = CGFloat(sender.currentPage) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    // MARK: - 초기 설정

    /// 뷰가 메모리에 로드된 후 호출됩니다.
    /// 페이지 개수와 초기 페이지 설정, 페이지 컨트롤 이벤트 연결, 스크롤뷰 inset 조정 등을 수행합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        // 페이지 컨트롤 초기화
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)

        // 스크롤 뷰의 자동 inset 조정을 비활성화
        scrollView.contentInsetAdjustmentBehavior = .never
    }
}
// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {

    /// 스크롤 뷰가 스크롤될 때 호출됩니다.
    /// 세로 스크롤을 방지하고, 수평 스크롤 위치에 따라 페이지 컨트롤 인덱스를 업데이트합니다.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 세로 스크롤 강제 차단
        scrollView.contentOffset.y = 0

        // 현재 페이지 계산 후 페이지 컨트롤에 적용
        let idx = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pageControl.currentPage = Int(idx)
    }
}
