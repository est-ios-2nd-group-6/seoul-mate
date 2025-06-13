//
//  HomeViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var rcmCourseListByAreaCollectionView: UICollectionView!

    var rcmCourseListByArea: [RecommandCourse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        rcmCourseListByArea = TourApiManager.shared.rcmCourseListByArea
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rcmCourseListByArea.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommandCourseCollectionViewCell", for: indexPath) as? RecommandCourseCollectionViewCell
        else { return UICollectionViewCell() }

        let course = rcmCourseListByArea[indexPath.item]

        cell.thumbnailImageView.image = UIImage(named: "subdetailimg")
        cell.titleLabel.text = course.title

        return cell
    }
    

}

