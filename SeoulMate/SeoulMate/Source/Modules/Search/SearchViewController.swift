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

    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var searchbarView: UISearchBar!
    
    var vcSourceType:SourceType?

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

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
            return cell
        }
        //        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:SearchResultTableViewCell.self), for: indexPath) as! SearchResultTableViewCell
        //        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

protocol SearchViewControllerDelegate: AnyObject {
    func didButtonTapped(cell: SearchResultTableHeaderCell)
}

extension SearchViewController: SearchViewControllerDelegate {
    func didButtonTapped(cell: SearchResultTableHeaderCell) {
        let alertVC = CustomAlertController()
        alertVC.delegate = self
        present(alertVC, animated: false)
    }
}

extension SearchViewController: CustomAlertControllerDelegate {
    func deleteRecentItem(_ alert: CustomAlertController) {
        self.tags.removeAll()
        self.tagCollectionView.reloadData()
    }
}
