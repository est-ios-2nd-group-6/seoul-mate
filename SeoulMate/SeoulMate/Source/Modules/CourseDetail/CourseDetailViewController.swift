//
//  CourseDetailViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

/**
 {
 "contentid": "2384832",
 "contenttypeid": "25",
 "subnum": "0",
 "subcontentid": "126525",
 "subname": "서울 선릉과 정릉 [유네스코 세계문화유산]",
 "subdetailoverview": "선릉에는 조선 제9대 성종과 그 계비 정현왕후 윤씨를 모신 선릉과 제11대 중종을 모신 정릉이 있다. 사적 제199호인 선정릉은 도시 가운데 있으면서도, 그리 잘 알려져 있지 않아 한적한 편이며, 조용히 산책을 즐길 수 있다. \n또한, 능을 둘러싸고 있는 철망 울타리를 철거하여 숲이 있는 구간에는 고풍스러운 담장을 쌓아 돌담길을 만들었다.",
 "subdetailimg": "http://tong.visitkorea.or.kr/cms/resource/83/1994283_image2_1.jpg",
 "subdetailalt": "서울_강남_지하철 9호선 연장 개통! 역 주변 가볼 만한 선.정릉과 봉은사03"
 },
 {
 "contentid": "2384832",
 "contenttypeid": "25",
 "subnum": "1",
 "subcontentid": "229901",
 "subname": "한국종합무역센터(코엑스)",
 "subdetailoverview": "한국종합무역센터는 국내외 무역업자들의 필요에 의해 1988년 9월 7일 설립된 대규모 비즈니스 타운이다. 무역회관, 한국종합전시장(COEX), 한국도심공항터미널, 인터콘티넨탈 호텔, 현대백화점 등이 한곳에 모여 있어 각종 무역 업무를 한 곳에서 처리할 수 있다.",
 "subdetailimg": "",
 "subdetailalt": ""
 },
 {
 "contentid": "2384832",
 "contenttypeid": "25",
 "subnum": "2",
 "subcontentid": "126999",
 "subname": "이태원 관광특구",
 "subdetailoverview": "이태원은 서울의 5개 관광특구 중 1997년에 최초로 지정된 관광특구다. 외국인 거주 인원이 2만 명 이상 되는 다국적 문화 지역으로 외국인 관광객에게 인지도가 높다. 외국인이 직접 운영하는 세계 음식점이 40여 개에 달하는 등 다국적 음식 거리가 조성되어 있어 이국 문화와 음식 체험이 가능하다. ",
 "subdetailimg": "",
 "subdetailalt": "이태원관광특구"
 }
 }
 */

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

                    place.description = place.description.replacingOccurrences(of: "<br />", with: "")

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
