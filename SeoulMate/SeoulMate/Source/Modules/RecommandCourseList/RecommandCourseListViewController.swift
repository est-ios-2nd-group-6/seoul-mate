//
//  RecommandCourseListViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

class RecommandCourseListViewController: UIViewController {
    @IBOutlet weak var RecommandCourseListTableView: UITableView!

    var courses: [RecommandCourse] = TourApiManager.shared.rcmCourseListByArea

    var selectedItem: RecommandCourse? = nil

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CourseDetailViewController {
            vc.course = selectedItem
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.title = "test"

        Task {
            for (index, course) in courses.enumerated() {
                let image = await ImageManager.shared.getImage(course.firstImageUrl)

                courses[index].image = image
            }

            RecommandCourseListTableView.reloadData()
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
