//
//  RecommandCourseListViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

/// 지역 또는 위치 기반의 추천 코스 목록을 표시하는 뷰 컨트롤러.
class RecommandCourseListViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var RecommandCourseListTableView: UITableView!

    // MARK: - Properties

    /// 코스 목록을 가져오는 기준. (지역/위치)
    var by: fetchCourseListType? = .area

    /// 테이블 뷰에 표시될 코스 데이터 배열.
    var courses: [RecommandCourse] = []

    /// 사용자가 선택한 코스 아이템. 상세 화면으로 전달됨.
    var selectedItem: RecommandCourse? = nil

    // MARK: - Navigation

    /// 화면 전환 직전, 선택된 코스 정보를 다음 뷰 컨트롤러에 전달.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecommandCourseDetailViewController {
            vc.course = selectedItem
        }
    }

    // MARK: - IBAction

    /// 이전 화면으로 이동.
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true

        // `by` 프로퍼티 값에 따라 TourApiManager에서 데이터를 가져와 courses 배열을 설정.
        switch by {
        case .area:
            courses = TourApiManager.shared.rcmCourseListByArea
        case .location:
            courses = TourApiManager.shared.rcmCourseListByLocation
        case nil:
            courses = []
        }
    }
}

// MARK: - UITableViewDataSource
extension RecommandCourseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "rcmCourseListCell", for: indexPath) as? RecommandCourseListTableViewCell else {
            return UITableViewCell()
        }

        let course = courses[indexPath.row]

        cell.listImageView.image = course.image
        cell.titleLabel.text = course.title

        return cell
    }
}

// MARK: - UITableViewDelegate
extension RecommandCourseListViewController: UITableViewDelegate {
    /// 사용자가 특정 행을 선택하면 `selectedItem`에 해당 코스를 저장.
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedItem = courses[indexPath.row]
        return indexPath
    }
}
