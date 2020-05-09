//
//  ExampleViewController.swift
//  Tabbar
//
//  Created by 张云龙 on 2020/5/6.
//  Copyright © 2020 张云龙. All rights reserved.
//

import Foundation
import UIKit

public class ExampleViewController: UIViewController {
   
    enum Style {
        case home
        case activity
        case add
        case message
        case me
    }
    
    var style: Style?
    
    init(style: Style) {
        
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 244.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
        
        view.backgroundColor = .white
        
        let label = UILabel(frame: .init(x: 10, y: 100, width: 100, height: 20))
        label.textColor = .red
        label.textAlignment = .center
        view.addSubview(label)
        label.center = view.center
        
        switch style {
        case .home:
            label.text = "home"
            rootTabBarController?.setRedDot(hidden: false, for: self)
        case .activity:
            label.text = "activity"
            tabBarItem.badgeValue = "99+"
        case .message:
            label.text = "message"
            tabBarItem.badgeValue = "3"
        case .me:
            label.text = "me"
        case .add:
            label.text = "add post"
        default:
            break
        }
    }
}
