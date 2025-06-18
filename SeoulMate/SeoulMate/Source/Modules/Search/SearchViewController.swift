//
//  SearchViewController.swift
//  SeoulMate
//
//  Created by DEV on 6/9/25.
//

import UIKit

enum SourceViewController {
    case home
    case schedule
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var searchbarView: UISearchBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tagCollectionViewTitle: UILabel!
    
    var comingVCType:SourceViewController?
//    var tags = ["오사카", "제주", "다낭", "파리", "도쿄", "부산", "방콕", "다낭", "괌", "삿포로"]
    var pois:[POI] = [] {
        didSet {
            self.tagCollectionView.reloadData()
            print(#line,pois.count)
        }
    }
    var POIsBackToVC:(([POI])->Void)?
    var items = [SearchResult]()
    var nameString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.showsVerticalScrollIndicator = false

        searchbarView.setImage(UIImage(), for: .search, state: .normal)
        searchbarView.becomeFirstResponder()

        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 3)
        tagCollectionView.collectionViewLayout = layout
        tagCollectionView.backgroundColor = .systemBackground
        
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.allowsSelection = true
        
        switch comingVCType {
            case .home:
                tagCollectionViewTitle.text = "인기 검색"
                break
            case .schedule:
                tagCollectionViewTitle.text = "최근 검색 장소"
                pois.removeAll()
                tagCollectionView.reloadData()
            default:
                break
        }

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    @IBAction func backToSchduleView(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
    @IBAction func dismissVC(_ sender: Any) {
        POIsBackToVC?(pois)
        navigationController?.popViewController(animated: true)
    }
    
}

extension SearchViewController: UICollectionViewDataSource,UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pois.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: TagCollectionViewCell.self),
                for: indexPath
            ) as! TagCollectionViewCell
        cell.setCell(text: pois[indexPath.item].name ?? "")
        cell.delegate = self
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let text = pois[indexPath.item].name ?? ""
        let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
        return CGSize(width: size.width + 60, height: size.height + 4)
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

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameString = items[indexPath.row].id
        performSegue(withIdentifier: "POIDetail", sender: nameString)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = SearchResultTableHeaderView()
            headerView.delegate = self
            return headerView
        }
        return nil
    }
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        }
        return 0
    }
}

protocol SearchViewControllerDelegate: AnyObject {
    func didRemoveAllButtonTapped()
    func didRemoveButtonTapped(cell: UITableViewCell)
    func didSelectButtonTapped(cell: UITableViewCell)
    func didDeselectButtonTapped(cell: UICollectionViewCell)
}

extension SearchViewController: SearchViewControllerDelegate {
    func didRemoveButtonTapped(cell: UITableViewCell) {
        guard let item = self.searchResultTableView.indexPath(for: cell) else { return }
        items.remove(at: item.row)
        DispatchQueue.main.async {
            self.searchResultTableView.deleteRows(at: [item], with: .fade)
        }
    }

    func didRemoveAllButtonTapped() {
        let alertVC = CustomAlertController()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.delegate = self
        present(alertVC, animated: false)
    }
    
    func didSelectButtonTapped(cell: UITableViewCell) {
        guard let item = self.searchResultTableView.indexPath(for: cell)
        else { return }
        let poi = POI(context: CoreDataManager.shared.context)
        poi.name = items[item.row].title
        poi.latitude = items[item.row].location.latitude
        poi.longitude = items[item.row].location.longitude
        poi.category = items[item.row].primaryTypeDisplayName?.text
        poi.placeID = items[item.row].id
        poi.imageURL = items[item.row].profileImage
        poi.openingHours = items[item.row].weekdayDescription?.joined(separator: "\n")
        pois.append(poi)
    }
    
    func didDeselectButtonTapped(cell: UICollectionViewCell) {
        guard let item = self.tagCollectionView.indexPath(for: cell) else { return }
        pois.remove(at: item.row)
    }
}


extension SearchViewController: CustomAlertControllerDelegate {
    func deleteRecentItem(_ alert: CustomAlertController) {
        self.items.removeAll()
        self.searchResultTableView.reloadData()
    }
}

extension SearchViewController: SearchResultTableHeaderViewDelegate {
    func didTapSomeButton() {
        didRemoveAllButtonTapped()
    }
}
