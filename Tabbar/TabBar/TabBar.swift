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
