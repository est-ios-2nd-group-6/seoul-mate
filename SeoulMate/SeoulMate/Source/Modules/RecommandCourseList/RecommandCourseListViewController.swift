//
//  RecommandCourseListViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

class RecommandCourseListViewController: UIViewController {
    @IBOutlet weak var RecommandCourseListTableView: UITableView!

    var by: fetchCourseListType? = .area

    var courses: [RecommandCourse] = []

    var selectedItem: RecommandCourse? = nil

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecommandCourseDetailViewController {
            vc.course = selectedItem
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true

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

extension RecommandCourseListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedItem = courses[indexPath.row]

        return indexPath
    }
}
