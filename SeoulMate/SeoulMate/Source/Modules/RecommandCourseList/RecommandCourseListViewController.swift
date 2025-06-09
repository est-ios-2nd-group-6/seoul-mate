//
//  RecommandCourseListViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

class RecommandCourseListViewController: UIViewController {
    let list = TourApiManager.shared.rcmCourseListByArea

    var selectedItem: RecommandCourse? = nil

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CourseDetailViewController {
            vc.course = selectedItem
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension RecommandCourseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rcmCourseListCell", for: indexPath)

        let course = list[indexPath.row]

        cell.textLabel?.text = course.title

        return cell
    }
}

extension RecommandCourseListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedItem = list[indexPath.row]

        return indexPath
    }
}
