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
    
    private(set) var animatedImage: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.repeatCount = .once
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
                self.updateBadgeValue()
            })
            .disposed(by: disposeBag)
        
        let _ = _item.rx.observe(Bool.self, "dotViewHidden")
            .subscribe(onNext: {[weak self] hidden in
                guard let self = self else { return }
                self.updateDotViewHidden()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func setupViews() {
        backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
        switch _item.style {
        case .customeView(let v):
            addSubview(v.view)
        case .local, .network:
            addSubview(imageView)
            addSubview(titleLabel)
            addSubview(dotView)
            addSubview(badgeContainer)
            badgeContainer.addSubview(badgeLabel)
        case .localGIF:
            addSubview(animatedImage)
            animatedImage.delegate = self
            addSubview(titleLabel)
            addSubview(dotView)
            addSubview(badgeContainer)
            badgeContainer.addSubview(badgeLabel)
    
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
            
            titleLabel.text = v.title
            titleLabel.font = isSelected ? .systemFont(ofSize: 10, weight: .bold) : .systemFont(ofSize: 10, weight: .regular)
            titleLabel.sizeToFit()
        case .network(let v):
            let imageUrl = isSelected ? v.selectedImageUrl : v.imageUrl
            imageView.kf.setImage(with: imageUrl)
            
            titleLabel.text = v.title
            titleLabel.font = isSelected ? .systemFont(ofSize: 10, weight: .bold) : .systemFont(ofSize: 10, weight: .regular)
            titleLabel.sizeToFit()
        case .localGIF(let v):
            if isSelected {
                guard let path = Bundle.main.path(forResource:v.selectedGIFName, ofType:"gif") else { return }
                let provider = LocalFileImageDataProvider(fileURL: .init(fileURLWithPath: path))
                animatedImage.kf.setImage(with: provider)
            } else {
                let imageName = v.normalImageName
                animatedImage.image = UIImage.init(named: imageName)
            }
            titleLabel.text = v.title
            titleLabel.font = isSelected ? .systemFont(ofSize: 10, weight: .bold) : .systemFont(ofSize: 10, weight: .regular)
            titleLabel.sizeToFit()
        case .customeView(_):
            break
        }
        setNeedsLayout()
    }
    
    private func updateBadgeValue() {
        badgeLabel.text = _item.badgeValue
        badgeContainer.isHidden = _item.badgeValue == nil
        badgeLabel.isHidden = _item.badgeValue == nil
        setNeedsLayout()
    }
    
    private func updateDotViewHidden() {
        dotView.isHidden = _item.dotViewHidden
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch _item.style {
        case .customeView(let v):
            v.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(v.insets)
            }
        case .local, .network:
            imageView.sizeToFit()
            imageView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-7)
            }
            layoutCommonUI(imageView: imageView)
        case .localGIF:
            animatedImage.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-7)
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
            layoutCommonUI(imageView: animatedImage)
        }
        
    }
    
    private func layoutCommonUI(imageView: UIImageView) {
        titleLabel.sizeToFit()
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-3)
            make.centerX.equalToSuperview()
        }
        let dotW: CGFloat = dotView.frame.width
        dotView.snp.makeConstraints { (make) in
            make.top.right.equalTo(imageView)
            make.size.equalTo(CGSize(width: dotW, height: dotW))
        }
        
        let badgeMargin: CGFloat = 2
        let badgeHeight: CGFloat = 14
        badgeLabel.sizeToFit()
        
        let textSize = badgeLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        let containarWidth = max(textSize.width + badgeMargin * 2, badgeHeight)
        badgeContainer.snp.remakeConstraints { (make) in
            make.top.equalTo(imageView)
            make.left.equalTo(imageView).offset(23)
            make.width.equalTo(containarWidth)
            make.height.equalTo(badgeHeight)
        }
        badgeLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        badgeContainer.layer.cornerRadius = badgeHeight / 2.0
    }
    
}

extension TabBarButton: AnimatedImageViewDelegate {
    
    func animatedImageViewDidFinishAnimating(_ imageView: Kingfisher.AnimatedImageView) {
        switch _item.style {
        case .localGIF(let v):
            let imageName = isSelected ? v.selectedGIFName : v.normalImageName
            animatedImage.image = UIImage.init(named: imageName)
        default: break
        }
        
    }
    
}
