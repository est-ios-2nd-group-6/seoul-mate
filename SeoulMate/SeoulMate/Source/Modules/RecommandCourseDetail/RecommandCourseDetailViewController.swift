//
//  RecommandCourseDetailViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

class RecommandCourseDetailViewController: UIViewController {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseListTableView: UITableView!


    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addToSchedule(_ sender: Any) {
		present(AddToScheduleSheetViewController(), animated: true)
    }
    
    var course: RecommandCourse?

    var places: [RecommandCoursePlace] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let cell = UINib(nibName: "RecommandCourseItemListTableViewCell", bundle: nil)
        courseListTableView.register(cell, forCellReuseIdentifier: "RecommandCourseItemListTableViewCell")


        Task {
            if let url = course?.firstImageUrl {
                let image = await ImageManager.shared.getImage(url)

                thumbnailImageView.image = image
            }

            if let id = course?.contentId {
                let courseSubItems = await TourApiManager.shared.fetchRcmCourseDetail(id) ?? []

                for courseSubItem in courseSubItems {
                    let commonDetailInfo = await TourApiManager.shared.fetchCommonDetailInfo(courseSubItem.subcontentid)

                    var place = RecommandCoursePlace(courseSubItem: courseSubItem)

                    place.description = place.description
                        .replacingOccurrences(of: "&lt;", with: "<")
                        .replacingOccurrences(of: "&gt;", with: ">")
                        .replacing(/<br\s*\/>/, with: "\n")
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                    place.type = PlaceType.init(rawValue: commonDetailInfo?.contenttypeid ?? "12")

                    let image = await ImageManager.shared.getImage(courseSubItem.subdetailimg)

                    place.image = image

                    places.append(place)
                }

                self.courseListTableView.reloadData()
            }
        }
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        thumbnailImageView.image = UIImage(named: "subdetailimg")
        titleLabel.text = course?.title
    }

}

extension RecommandCourseDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecommandCourseItemListTableViewCell", for: indexPath) as? RecommandCourseItemListTableViewCell else {
            return UITableViewCell()
        }

        let row = indexPath.row

        let subItem = places[indexPath.item]

        print(subItem)

        cell.contentWrapperView.layer.cornerRadius = 8

        cell.contentWrapperView.layer.borderWidth = 1
        cell.contentWrapperView.layer.borderColor = UIColor.tertiaryLabel.withAlphaComponent(0.1).cgColor
        
        cell.contentWrapperView.layer.shadowColor = UIColor.black.cgColor
        cell.contentWrapperView.layer.shadowOpacity = 0.2
        cell.contentWrapperView.layer.shadowRadius = 10
        cell.contentWrapperView.layer.shadowOffset = CGSize(width: 0, height: 0)

        cell.wrapperStackView.layer.cornerRadius = 8
        cell.wrapperStackView.clipsToBounds = true

        cell.indexIndicator.text = String(row + 1)
        cell.indexIndicator.layer.cornerRadius = 10
        cell.indexIndicator.clipsToBounds = true

        if let image = subItem.image {
            cell.cellImageView?.image = image
        } else {
            cell.cellImageView?.removeFromSuperview()
            cell.titleLabel.topAnchor.constraint(equalTo: cell.wrapperStackView.topAnchor, constant: 12).isActive = true
        }

        cell.titleLabel.text = subItem.name

        cell.typeLabel.text = subItem.type?.name

        return cell
    }
}
