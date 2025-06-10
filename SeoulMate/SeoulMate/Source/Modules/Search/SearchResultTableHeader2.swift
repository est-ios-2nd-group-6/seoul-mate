//
//  SearchResultTableHeader.swift
//  SeoulMate
//
//  Created by DEV on 6/10/25.
//

import UIKit

class SearchResultTableHeader2: UITableViewHeaderFooterView {
    
    func setupHeaderView() -> UIView{
        let titleView:UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 22, weight: .bold)
            label.text = "최근 검색"
            return label
        }()
        
        let deleteAllButton:UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("모두 삭제", for: .normal)
            button.setTitleColor(.gray, for: .normal)
            return button
        }()
        
        let headerView:UIView = {
            let view = UIView()
            view.addSubview(titleView)
            view.addSubview(deleteAllButton)
            return view
        }()
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            //        titleView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            deleteAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            //        deleteAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        return headerView
    }
    
    func deleteAllAction(){
        print("called")
    }

}
