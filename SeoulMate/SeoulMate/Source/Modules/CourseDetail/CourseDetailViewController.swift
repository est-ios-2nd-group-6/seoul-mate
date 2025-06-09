//
//  CourseDetailViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

class CourseDetailViewController: UIViewController {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseListTableView: UITableView!

    @IBOutlet weak var courseListTableViewHeight: NSLayoutConstraint!

    var course: RecommandCourse?

    var places: [RecommandCoursePlace] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = course?.contentId {
            Task {

                let courseSubItems = await TourApiManager.shared.fetchRcmCourseDetail(id) ?? []

                for courseSubItem in courseSubItems {
                    var place = RecommandCoursePlace(courseSubItem: courseSubItem)

                    place.description = place.description
                        .replacingOccurrences(of: "&lt;", with: "<")
                        .replacingOccurrences(of: "&gt;", with: ">")
                        .replacing(/<br\s*\/>/, with: "\n")
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                    let image = await ImageManager.shared.getImage(courseSubItem.subdetailimg)

                    place.image = image

                    places.append(place)
                }

                self.courseListTableView.reloadData()
                self.courseListTableViewHeight.constant = 1500
            }
        }
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        thumbnailImageView.image = UIImage(named: "subdetailimg")
        titleLabel.text = course?.title
    }

}


extension CourseDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "courseSubItemCell", for: indexPath) as? CourseItemListTableViewCell else {
            return UITableViewCell()
        }

        let subItem = places[indexPath.item]

        let indicatorFrame = cell.indexIndicator.frame
        cell.indexIndicator.layer.cornerRadius = indicatorFrame.height / 2
        cell.indexIndicator.clipsToBounds = true

        if let subnum = Int(subItem.subnum) {
            cell.indexIndicator.text = String(subnum + 1)
        }

        cell.titleLabel.text = subItem.name
        cell.descriptionLabel.text = subItem.description

        if let image = subItem.image {
            cell.itemImageView.image = image
        } else {
            cell.itemImageView.removeFromSuperview()
        }

        return cell
    }
}

extension CourseDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == places.count - 1 {
            print(self.courseListTableView.contentSize.height)
        }

    }
}
