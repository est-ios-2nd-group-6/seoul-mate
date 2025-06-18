//
//  SearchResultTableHeaderView.swift
//  SeoulMate
//
//  Created by DEV on 6/17/25.
//

import UIKit

class SearchResultTableHeaderView: UIView {
    
    weak var delegate: SearchResultTableHeaderViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체 삭제", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .systemBackground
        addSubview(titleLabel)
        addSubview(actionButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        delegate?.didTapSomeButton()
    }
}

protocol SearchResultTableHeaderViewDelegate: AnyObject {
    func didTapSomeButton()
}
