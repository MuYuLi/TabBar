//
//  TabBarItem.swift
//  Tabbar
//
//  Created by 张云龙 on 2020/5/7.
//  Copyright © 2020 张云龙. All rights reserved.
//

import UIKit

class TabBarItem: UITabBarItem {
    
    enum Style {
        /// 本地图片
        case local(LocalImage)
        
        /// 网络图片
        case network(NetworkImage)
        
        /// 自定义view
        case customeView(CustomView)
       
        /// 本地gif
        case localGIF(LocalGIF)
        
        struct LocalImage {
            var image: UIImage?
            var selectedImage: UIImage?
            var title: String
        }
        
        struct NetworkImage {
            var imageUrl: URL?
            var selectedImageUrl: URL?
            var title: String
        }
        
        struct CustomView {
            var view : UIView
            var insets = UIEdgeInsets.zero
        }
        struct LocalGIF {
            var normalImageName: String
            var selectedGIFName: String
            var title: String
        }
    }
    
    var style: Style = .local(.init(image: UIImage(), selectedImage: UIImage(), title: ""))
    
    @objc dynamic var dotViewHidden: Bool = true
    
    public init(style: Style) {
        super.init()
        self.style = style
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
