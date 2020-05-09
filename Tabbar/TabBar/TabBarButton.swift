//
//  TabBarButton.swift
//  Tabbar
//
//  Created by 张云龙 on 2020/5/7.
//  Copyright © 2020 张云龙. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher
import SnapKit
import RxCocoa

class TabBarButton: UIControl {
    
    private var disposeBag = DisposeBag()
    
    private(set) var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private(set) var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = UIColor(red: 64/255.0, green: 64/255.0, blue: 68/255.0, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 10, weight: .regular)
        return titleLabel
    }()
    
    private(set) var badgeContainer: UIView = {
        let badgeContainer = UIView()
        badgeContainer.isHidden = true
        badgeContainer.backgroundColor = UIColor(red: 249/255.0, green: 97/255.0, blue: 73/255.0, alpha: 1)
        return badgeContainer
    }()
    
    private(set) var badgeLabel: UILabel = {
        let badgeLabel = UILabel()
        badgeLabel.font = .systemFont(ofSize: 10)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        return badgeLabel
    }()
    
    private(set) var dotView: UIView = {
        let dotSize: CGFloat = 8.0
        let dotView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize)))
        dotView.layer.cornerRadius = dotSize / 2.0
        dotView.layer.shouldRasterize = true
        dotView.backgroundColor = UIColor(red: 249/255.0, green: 97/255.0, blue: 73/255.0, alpha: 1)
        dotView.layer.rasterizationScale = UIScreen.main.scale
        return dotView
    }()
    
    var item: TabBarItem? {
        set {
            guard let item = newValue else { return }
            _item = item
        }
        get {
            return _item
        }
    }
    
    @objc dynamic var _item: TabBarItem = TabBarItem(){
        didSet {
            updateDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            updateDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addObservers()
    }
    
    required init(item: TabBarItem) {
        super.init(frame: .zero)
        self.item = item
        addObservers()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        addObservers()
    }
    
    private func addObservers() {
        let _ = _item.rx.observe(String.self, "badgeValue")
            .subscribe(onNext: {[weak self] value in
                guard let self = self else { return }
                self.updateDisplay()
            })
            .disposed(by: disposeBag)
        
        let _ = _item.rx.observe(Bool.self, "dotViewHidden")
            .subscribe(onNext: {[weak self] hidden in
                guard let self = self else { return }
                self.updateDisplay()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
        switch _item.style {
        case .customeView(let v):
            addSubview(v.view)
        case .local, .network:
            addSubview(titleLabel)
            addSubview(imageView)
            addSubview(dotView)
            badgeContainer.addSubview(badgeLabel)
            addSubview(badgeContainer)
        }
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
    }
    
}

extension TabBarButton {
    
    private func updateDisplay() {
        switch _item.style {
        case .local(let v):
            imageView.image = isSelected ? v.selectedImage : v.image
            
            titleLabel.font = isSelected ? .systemFont(ofSize: 10, weight: .bold) : .systemFont(ofSize: 10, weight: .regular)
            titleLabel.text = v.title
            titleLabel.sizeToFit()
            
            badgeLabel.text = _item.badgeValue
            badgeContainer.isHidden = _item.badgeValue == nil
            badgeLabel.isHidden = _item.badgeValue == nil
            
            dotView.isHidden = _item.dotViewHidden
        case .network(let v):
            let imageUrl = isSelected ? v.selectedImageUrl : v.imageUrl
            imageView.kf.setImage(with: imageUrl)
            titleLabel.font = isSelected ? .systemFont(ofSize: 10, weight: .bold) : .systemFont(ofSize: 10, weight: .regular)
            titleLabel.text = v.title
            titleLabel.sizeToFit()
            
            badgeLabel.text = _item.badgeValue
            badgeContainer.isHidden = _item.badgeValue == nil
            badgeLabel.isHidden = _item.badgeValue == nil
            
            
            dotView.isHidden = _item.dotViewHidden
        case .customeView(_):
            break
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch _item.style {
        case .customeView(let v):
            v.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(v.insets)
            }
        case .local, .network:
            
            titleLabel.sizeToFit()
            titleLabel.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-8)
                make.centerX.equalToSuperview()
            }
            imageView.sizeToFit()
            imageView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-7)
            }
            
            let dotW: CGFloat = dotView.frame.width
            dotView.snp.makeConstraints { (make) in
                make.centerX.equalTo(imageView.snp.right)
                make.centerY.equalTo(imageView.snp.top)
                make.size.equalTo(CGSize(width: dotW, height: dotW))
            }
            
            let badgeMargin: CGFloat = 2
            let badgeHeight: CGFloat = 14
            badgeLabel.sizeToFit()
            
            let textSize = badgeLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            let containarWidth = max(textSize.width + badgeMargin * 2, badgeHeight)
            
            badgeContainer.snp.remakeConstraints { (make) in
                make.top.equalTo(badgeMargin)
                make.left.equalTo(imageView.snp.right).offset(-badgeMargin)
                make.width.equalTo(containarWidth)
                make.height.equalTo(badgeHeight)
            }
            badgeLabel.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            badgeContainer.layer.cornerRadius = badgeHeight / 2.0
            
        }
    }
}

