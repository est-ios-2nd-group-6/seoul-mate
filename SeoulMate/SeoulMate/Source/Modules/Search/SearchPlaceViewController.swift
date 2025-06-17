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
            print(items)
        }
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
        return cell
    }
}

extension SearchPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameString = items[indexPath.row].id
        performSegue(withIdentifier: "POIDetail", sender: nameString)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "최근 검색 장소"
    }
}

protocol SearchPlaceViewControllerDelegate: AnyObject {
    func didRemoveAllButtonTapped()
    func didRemoveButtonTapped(cell: UITableViewCell)
}

extension SearchPlaceViewController: SearchViewControllerDelegate {
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

extension SearchPlaceViewController: CustomAlertControllerDelegate {
    func deleteRecentItem(_ alert: CustomAlertController) {
        self.items.removeAll()
        self.searchResultTableView.reloadData()
    }
}
