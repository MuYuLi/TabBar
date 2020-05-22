//
//  PostTabBarButton.swift
//  Tabbar
//
//  Created by 张云龙 on 2020/5/7.
//  Copyright © 2020 张云龙. All rights reserved.
//

import UIKit
import SnapKit

class PostTabBarButton: UIView {
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 10, weight: .regular)
        
        return view
    }()
    
    convenience init(image: UIImage?, title: String) {
        self.init(frame: .zero)
        
        imageView.image = image
        titleLabel.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.top.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-3)
            make.centerX.equalToSuperview()
        }
    }
}
