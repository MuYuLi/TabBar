//
//  TabBarController.swift
//  Tabbar
//
//  Created by 张云龙 on 2020/5/6.
//  Copyright © 2020 张云龙. All rights reserved.
//

import UIKit
import Rswift

class TabBarController: UITabBarController {
    
    
    let customViewInsets: UIEdgeInsets = .init(top: -7, left: 0, bottom: 0, right: 0)
    var totalCustomBarHeight: CGFloat {
        get {
            return ((tabBar as? TabBar)?.barHeight ?? tabBar.frame.height) + customViewInsets.top
        }
    }
    
    private(set) lazy var homeVC: ExampleViewController = {
        let vc = ExampleViewController(style: .home)
        vc.tabBarItem = TabBarItem(
            style: .local(.init(
                image: R.image.tab_home(),
                selectedImage: R.image.tab_homes(),
                title: "首页"
                ))
        )
        return vc
    }()
    
    private(set) lazy var forumVC: ExampleViewController = {
        let vc = ExampleViewController(style: .activity)
        vc.tabBarItem = TabBarItem(
            style: .local(.init(
                image: R.image.tab_find(),
                selectedImage: R.image.tab_finds(),
                title: "发现"
                ))
        )
        return vc
    }()
    
    private(set) lazy var emptyVC: UIViewController = {
        let vc = ExampleViewController(style: .add)
        let postView = PostTabBarButton(image: R.image.ic_tab_add_post(), title: "发布")
        postView.isUserInteractionEnabled = false
        vc.tabBarItem = TabBarItem(
            style: .customeView(.init(
                view: postView,
                insets: customViewInsets
                ))
        )
        return vc
    }()
    
    private(set) lazy var messageVC: ExampleViewController = {
        let vc = ExampleViewController(style: .message)
        vc.tabBarItem = TabBarItem(
            style: .local(.init(
                image: R.image.tab_community(),
                selectedImage: R.image.tab_communitys(),
                title: "消息"
                ))
        )
        return vc
    }()
    
    private(set) lazy var meVC: ExampleViewController = {
        let vc = ExampleViewController(style: .me)
        vc.tabBarItem = TabBarItem(
            style:.localGIF(.init(normalImageName: "tab_me",
                                  selectedGIFName: "tab_mes",
                                  title: "我的"
                ))
        )
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
        
        guard tabBar as? TabBar == nil else {
            return
        }
        let tabBar = TabBar()
        tabBar.customDelegate = self
        tabBar.backgroundImage = R.image.background_dark()
        tabBar.shadowImage = R.image.transparent()
        setValue(tabBar, forKey: "tabBar")
        
        viewControllers = [ homeVC, forumVC, emptyVC, messageVC, meVC ]
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension TabBarController {
    /// 设置红点view
    func setRedDot(hidden: Bool, for controller: UIViewController) {
        guard let tabBarItem = controller.tabBarItem as? TabBarItem else { return }
        tabBarItem.dotViewHidden = hidden
    }
    
    private func postButtonPressed() {
        
        let alert = UIAlertController(title: "内容", message: "请选择发帖形式", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        switch viewController {
        case emptyVC:
            postButtonPressed()
            return false
        case messageVC, meVC, homeVC, forumVC:
            return true
        default:
            break
        }
        return true
    }
    
}

extension TabBarController: TabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, shouldSelect item: UITabBarItem) -> Bool {
        if let idx = tabBar.items?.firstIndex(of: item), let vc = viewControllers?[idx] {
            return delegate?.tabBarController?(self, shouldSelect: vc) ?? true
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item) else {
            return
        }
        if let controller = viewControllers?[idx] {
            selectedIndex = idx
            delegate?.tabBarController?(self, didSelect: controller)
        }
    }
}

extension TabBarController {
    
    override var shouldAutorotate: Bool {
        false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [ .portrait ]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
    
}

extension UIViewController {
    
    var rootTabBarController: TabBarController? {
        guard let controller = tabBarController as? TabBarController else { return nil }
        return controller
    }
    
}

extension TabBarController {
    
    /// 自定义barHeight
    var barHeight: CGFloat {
        get {
            return (tabBar as? TabBar)?.barHeight ?? tabBar.frame.height
        }
        set {
            (tabBar as? TabBar)?.barHeight = newValue
            self.setValue(tabBar, forKey: "tabBar")
        }
    }
    
    private func updateTabBarFrame() {
        var tabFrame = tabBar.frame
        if #available(iOS 11.0, *) {
            tabFrame.size.height = barHeight + view.safeAreaInsets.bottom
        } else {
            tabFrame.size.height = barHeight
        }
        tabFrame.origin.y = self.view.frame.size.height - tabFrame.size.height
        tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateTabBarFrame()
    }
}
