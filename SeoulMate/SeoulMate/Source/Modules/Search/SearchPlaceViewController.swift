//
//  SearchViewController.swift
//  SeoulMate
//
//  Created by DEV on 6/9/25.
//

import UIKit

class SearchPlaceViewController: UIViewController {

    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var searchbarView: UISearchBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scheduleAddButton: UIButton!

    var items = [SearchResult]()
    var selectedItems = [SearchResult]()
    var nameString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.showsVerticalScrollIndicator = false

        searchbarView.setImage(UIImage(), for: .search, state: .normal)
        searchbarView.becomeFirstResponder()

        scheduleAddButton.layer.masksToBounds = true
        scheduleAddButton.layer.cornerRadius = 15
        scheduleAddButton.isHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "POIDetail" {
            if let nav = segue.destination as? UINavigationController,
                let detailVC = nav.topViewController as? POIDetailViewController
            {
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
            await TourApiManager_hs.shared.fetchGooglePlaceAPIByKeyword(keyword: keyword)
            items = TourApiManager_hs.shared.searchByTitleResultList
            self.searchResultTableView.reloadData()
        }
    }
    @IBAction func vcDismiss(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
}

extension SearchPlaceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 {
            return items.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: String(describing: SearchViewFromMapTableViewCell.self),
                for: indexPath
            ) as! SearchViewFromMapTableViewCell
        if items.count != 0 {
            cell.placeTitleLabel.text = items[indexPath.row].title
            cell.placeCategoryLabel.text = items[indexPath.row].primaryTypeDisplayName?.text
            if let profileURL = items[indexPath.row].profileImage, let apiKey = Bundle.main.googleApiKey,
               let url = URL(
                string:
                    "https://places.googleapis.com/v1/\(profileURL)/media?maxHeightPx=50&maxWidthPx=50&key=\(apiKey)"
               )
            {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.placeImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
            cell.delegate = self
        }
        return cell
    }
}

extension SearchPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "POIDetail", sender: nameString)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "최근 검색 장소"
    }
}

protocol SearchPlaceViewControllerDelegate: AnyObject {
    func didPlaceScheduleAddTapped(cell: UITableViewCell)
}

extension SearchPlaceViewController: SearchPlaceViewControllerDelegate {
    func didPlaceScheduleAddTapped(cell: UITableViewCell) {
        guard let item = self.searchResultTableView.indexPath(for: cell) else { return }
        self.searchResultTableView.reloadRows(at: [item], with: .none)
    }
    
}

