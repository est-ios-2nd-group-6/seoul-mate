//
//  SearchViewController.swift
//  SeoulMate
//
//  Created by DEV on 6/9/25.
//

import UIKit

class SearchViewController: UIViewController {

    var tags = ["오사카","제주","다낭","파리","도쿄","부산","방콕","다낭","괌","삿포로",]
    
    @IBOutlet weak var searchResultTableView: UITableView!
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    @IBOutlet weak var searchbarView: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchResultTableView.dataSource = self
//        searchResultTableView.showsVerticalScrollIndicator = false
        
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

extension SearchViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TagCollectionViewCell.self), for: indexPath) as! TagCollectionViewCell
        cell.setCell(text: tags[indexPath.item])
        print(#function)
        return cell
    }
}

extension SearchViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = tags[indexPath.item]
        let size = (text as NSString).size(withAttributes: [.font:UIFont.systemFont(ofSize: 14)])
        return CGSize(width: size.width+24, height: size.height+16)
    }
}

extension SearchViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(tags[indexPath.row])
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        self.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return attributes
    }
}

extension SearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:SearchResultTableViewCell.self), for: indexPath) as! SearchResultTableViewCell
        return cell
    }
    
}
