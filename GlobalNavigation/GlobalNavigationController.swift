//
//  NavigationController.swift
//  IHeardYouLikeViewControllers
//
//  Created by Oleksii Horishnii on 4/25/17.
//  Copyright © 2017 Oleksii Horishnii. All rights reserved.
//

import Foundation

public class GlobalNavigationController: UINavigationController {
    public var controllers: [LogicalController] = []
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.controllers = [rootViewController]
    }
    
    public init(rootViewController: LogicalController) {
        let vc = rootViewController.mainVC
        super.init(rootViewController: vc)
        self.controllers = [rootViewController]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.controllers = self.viewControllers
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func pushLogicalController(_ logicalController: LogicalController, animated: Bool) {
        self.controllers.append(logicalController)
        self.pushViewController(logicalController.mainVC, animated: animated)
    }
    
    override public func popViewController(animated: Bool) -> UIViewController? {
        if self.controllers.count > 1 {
            self.controllers.removeLast()
        }
        return super.popViewController(animated: animated)
    }
    
    override public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let first = self.controllers.first {
            self.controllers = [first]
        } else {
            self.controllers = []
        }
        return super.popToRootViewController(animated: animated)
    }
}

public extension LogicalController {
    func maybeNavigation() -> GlobalNavigationController? {
        return self.mainVC as? GlobalNavigationController
    }
}
