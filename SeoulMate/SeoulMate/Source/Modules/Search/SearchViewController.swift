//
//  SearchViewController.swift
//  SeoulMate
//
//  Created by DEV on 6/9/25.
//

import UIKit

enum SourceType {
    case home
    case map
}

class SearchViewController: UIViewController {

    var tags = ["오사카", "제주", "다낭", "파리", "도쿄", "부산", "방콕", "다낭", "괌", "삿포로"]
    var items = [SearchResult]()

    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var searchbarView: UISearchBar!
    @IBOutlet weak var searchBar: UISearchBar!

    var vcSourceType: SourceType?
    var nameString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.showsVerticalScrollIndicator = false

        searchbarView.setImage(UIImage(), for: .search, state: .normal)
        searchbarView.becomeFirstResponder()

        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self

        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 3)
        tagCollectionView.collectionViewLayout = layout
        tagCollectionView.backgroundColor = .systemBackground
        
        Task {
            items.removeAll()
            await TourApiManager_hs.shared.fetchGooglePlaceAPIByKeyword(keyword: "서울 맛집")
            items = TourApiManager_hs.shared.searchByTitleResultList
            self.searchResultTableView.reloadData()
            self.searchBar.text = "서울 맛집"
            guard let placeName = nameString else { return }
            await TourApiManager_hs.shared.fetchGooglePlaceAPIByName(name: placeName)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "POIDetail" {
            if let nav = segue.destination as? UINavigationController,
               let detailVC = nav.topViewController as? POIDetailViewController {
                detailVC.nameLabel = nameString ?? ""
            }
        }
    }

    @IBAction func searchItemButton(_ sender: Any) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        searchBar.resignFirstResponder()
        Task {
            self.searchResultTableView.isHidden = false
            items.removeAll()
            //            await TourApiManager_hs.shared.fetchRcmCourseList(keyword: keyword)
            await TourApiManager_hs.shared.fetchGooglePlaceAPIByKeyword(keyword: keyword)
            items = TourApiManager_hs.shared.searchByTitleResultList
            self.searchResultTableView.reloadData()
        }
    }

}

extension SearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: TagCollectionViewCell.self),
                for: indexPath
            ) as! TagCollectionViewCell
        cell.setCell(text: tags[indexPath.item])
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let text = tags[indexPath.item]
        let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
        return CGSize(width: size.width + 24, height: size.height + 16)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 {
            return items.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultTableHeaderCell.self))
                as! SearchResultTableHeaderCell
            cell.delegate = self
            return cell
        default:
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SearchResultTableViewCell.self),
                    for: indexPath
                ) as! SearchResultTableViewCell
            if items.count != 0 {
                cell.titleLabel.text = items[indexPath.row].title
                cell.subTitleLabel.text = items[indexPath.row].primaryTypeDisplayName?.text
                if let profileURL = items[indexPath.row].profileImage, let apiKey = Bundle.main.googleApiKey,
                    let url = URL(
                        string:
                            "https://places.googleapis.com/v1/\(profileURL)/media?maxHeightPx=50&maxWidthPx=50&key=\(apiKey)"
                    )
                {
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        if let data = data {
                            DispatchQueue.main.async {
                                cell.searchImageView.image = UIImage(data: data)
                            }
                        }
                    }.resume()
                }
                cell.delegate = self
            }
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameString = items[indexPath.row].id
        performSegue(withIdentifier: "POIDetail", sender: nameString)
    }

}

protocol SearchViewControllerDelegate: AnyObject {
    func didRemoveAllButtonTapped()
    func didRemoveButtonTapped(cell: UITableViewCell)
}

extension SearchViewController: SearchViewControllerDelegate {
    func didRemoveButtonTapped(cell: UITableViewCell) {
        guard let item = self.searchResultTableView.indexPath(for: cell) else { return }
        items.remove(at: item.row)
        DispatchQueue.main.async {
            self.searchResultTableView.deleteRows(at: [item], with: .fade)
            if self.items.count == 1 {
                self.searchResultTableView.isHidden = true
            }
        }
    }

    func didRemoveAllButtonTapped() {
        let alertVC = CustomAlertController()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.delegate = self
        present(alertVC, animated: false)
    }
}

extension SearchViewController: CustomAlertControllerDelegate {
    func deleteRecentItem(_ alert: CustomAlertController) {
        self.items.removeAll()
        self.searchResultTableView.reloadData()
    }
}
