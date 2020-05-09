//
//  ViewController.swift
//  Tabbar
//
//  Created by 张云龙 on 2020/4/22.
//  Copyright © 2020 张云龙. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        
        let sender = UIButton()
        sender.backgroundColor = .red
        sender.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
        view.addSubview(sender)
        sender.addTarget(self, action: #selector(action), for: .touchUpInside)
        
        let sender1 = UIButton()
        sender1.backgroundColor = .green
        sender1.frame = CGRect.init(x: 200, y: 200, width: 100, height: 100)
        view.addSubview(sender1)
        sender1.addTarget(self, action: #selector(action1), for: .touchUpInside)
    }
    
    @objc func action() {
        self.present(systemStyle(), animated: true, completion: nil)
    }
    
    @objc func action1() {
        let rootTabBarController = TabBarController()
        self.present(rootTabBarController, animated: true, completion: nil)
    }
    
    func systemStyle() -> UITabBarController {
        let tabBarController = UITabBarController()
        let v1 = ExampleViewController(style: .home)
        let v2 = ExampleViewController(style: .activity)
        let v3 = ExampleViewController(style: .add)
        let v4 = ExampleViewController(style: .message)
        let v5 = ExampleViewController(style: .me)
        
        v1.tabBarItem = UITabBarItem.init(title: "Home", image: R.image.tab_ic_home(), selectedImage: R.image.tab_ic_homes())
        v2.tabBarItem = UITabBarItem.init(title: "Find", image: R.image.tab_ic_dynamic(), selectedImage: R.image.tab_ic_dynamics())
        v3.tabBarItem = UITabBarItem.init(title: "Photo", image: UIImage(named: "ic_tab_add_post"), selectedImage: UIImage(named: "ic_tab_add_post"))
        v4.tabBarItem = UITabBarItem.init(title: "Favor", image: R.image.tab_ic_information(), selectedImage: R.image.tab_ic_informations())
        v5.tabBarItem = UITabBarItem.init(title: "Me", image: R.image.tab_ic_me(), selectedImage: R.image.tab_ic_mes())
        
        tabBarController.tabBar.shadowImage = nil
        
        tabBarController.viewControllers = [v1, v2, v3, v4, v5]
        
        return tabBarController
    }
 
}

