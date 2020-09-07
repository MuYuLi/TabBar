//
//  TabBar.swift
//  Tabbar
//
//  Created by 张云龙 on 2020/5/7.
//  Copyright © 2020 张云龙. All rights reserved.
//

import UIKit

protocol TabBarDelegate: NSObjectProtocol {
    func tabBar(_ tabBar: UITabBar, shouldSelect item: UITabBarItem) -> Bool
}

class TabBar: UITabBar {
    
    weak var customDelegate: TabBarDelegate?
    var containers = [TabBarButton]()
    var barHeight: CGFloat = 54
   
    private lazy var borderLayer: CAShapeLayer = {
        let borderLayer = CAShapeLayer()
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.init(red: 239/255.0, green: 241/255.0, blue: 244/255.0, alpha: 1).cgColor
        borderLayer.position = .zero
        borderLayer.anchorPoint = .zero
        borderLayer.lineJoin = .round
        
        borderLayer.shadowColor = UIColor.init(red: 239/255.0, green: 241/255.0, blue: 244/255.0, alpha: 1).cgColor
        borderLayer.shadowOffset = CGSize(width: 0, height: -1)
        borderLayer.shadowRadius = 1
        borderLayer.shadowOpacity = 1
        return borderLayer
    }()
    
    override var selectedItem: UITabBarItem? {
        willSet {
            guard let newValue = newValue else {
                containers.forEach { $0.setSelected(false) }
                return
            }
            
            let btnItems: [UITabBarItem?] = containers.map { $0.item }
            for (index, value) in btnItems.enumerated() {
                if value === newValue {
                    select(itemAt: index, animated: false)
                }
            }
        }
    }
    
    open override var items: [UITabBarItem]? {
        didSet {
            reload()
        }
    }
    
    open override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        reload()
    }
    
    public func reload() {
        removeAllSubViews()
        guard let tabBarItems = items else {
            return
        }
        for item in tabBarItems {
            guard let tabBarItem = item as? TabBarItem else { return }
            
            let container = TabBarButton(item: tabBarItem)
            addSubview(container)
            containers.append(container)
            
            container.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
            
            if selectedItem != nil && container.item === selectedItem {
                container.setSelected(true)
            }
        }
        setNeedsLayout()
    }
    
    func removeAllSubViews() {
        for container in containers {
            container.removeFromSuperview()
        }
        containers.removeAll()
        subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }.forEach { $0.removeFromSuperview() }
        
    }
    
}

extension TabBar {
    
    @objc private func btnPressed(sender: UIControl) {
        guard let sender = sender as? TabBarButton else {
            return
        }
        
        if let item = sender.item, let items = items, items.contains(item) {
            if (customDelegate?.tabBar(self, shouldSelect: item) ?? true) == false {
                return
            }
            
            containers.forEach { (button) in
                guard button !== sender else {
                    return
                }
                button.setSelected(false)
            }
            sender.setSelected(true)
            
            delegate?.tabBar?(self, didSelect: item)
        }
    }
    
    func select(itemAt index: Int, animated: Bool = false) {
        guard index < containers.count else {
            return
        }
        let selectedbutton = containers[index]
        containers.forEach { (button) in
            guard button !== selectedbutton else {
                return
            }
            button.setSelected(false)
        }
        selectedbutton.setSelected(true)
    }
}

extension TabBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let btnWidth = max(0, (bounds.width) / CGFloat(containers.count))
        let bottomOffset: CGFloat
        if #available(iOS 11.0, *) {
            bottomOffset = safeAreaInsets.bottom
        } else {
            bottomOffset = 0
        }
        let btnHeight = bounds.height - bottomOffset
        var lastX: CGFloat = 0
        for button in containers {
            
            button.frame = CGRect(x: lastX, y: 0, width: btnWidth, height: btnHeight)
            lastX = button.frame.maxX
            button.setNeedsLayout()
        }
        addshadowPath()
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = barHeight
        if #available(iOS 11.0, *) {
            sizeThatFits.height = sizeThatFits.height + safeAreaInsets.bottom
        }
        return sizeThatFits
    }
}

extension TabBar {
    
    private func addshadowPath() {
        borderLayer.bounds = bounds

        let pitWidth: CGFloat = 37
        let topY: CGFloat = -7
        let startPointX = CGFloat((bounds.width - pitWidth) * 0.5)
        let endPoint = CGPoint(x: startPointX + pitWidth, y: 0)
        let pitCenterTopPoint = CGPoint(x: startPointX + (pitWidth / 2), y: topY)
        
        let leftBottomP = CGPoint(x: startPointX + abs(topY / 2), y: 0)
        let leftTopP = CGPoint(x: pitCenterTopPoint.x - abs(10), y: topY)
        let rightBottomP = CGPoint(x: endPoint.x - abs(topY / 2), y: 0)
        let rightTopP = CGPoint(x: pitCenterTopPoint.x + abs(10), y: topY)
        
        let borderPath = CGMutablePath()
        borderPath.move(to: .zero)
        borderPath.addArc(center: CGPoint(x: 15, y: 15), radius: 15, startAngle: .pi, endAngle: -.pi / 2, clockwise: false)
        borderPath.addLine(to: CGPoint(x: startPointX, y: 0))
        borderPath.addCurve(to: pitCenterTopPoint, control1: leftBottomP, control2: leftTopP)
        borderPath.addCurve(to: endPoint, control1: rightTopP, control2: rightBottomP)
        borderPath.addLine(to: CGPoint(x: bounds.width, y: 0))
        borderPath.addArc(center: CGPoint(x: bounds.width - 15, y: 15), radius: 15, startAngle: -.pi / 2, endAngle: 0, clockwise: false)
        
        borderLayer.path = borderPath
        
    }
    
}

