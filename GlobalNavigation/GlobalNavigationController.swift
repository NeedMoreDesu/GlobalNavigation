//
//  NavigationController.swift
//  IHeardYouLikeViewControllers
//
//  Created by Oleksii Horishnii on 4/25/17.
//  Copyright © 2017 Oleksii Horishnii. All rights reserved.
//

import Foundation

public class GlobalNavigationController: UINavigationController, UINavigationControllerDelegate {
    //MARK:- initializers
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
    
    //MARK:- lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    //MARK:- variables
    public var controllers: [LogicalController] = []
    private var onSuccessfullTransition: [(() -> Void)] = []
    
    //MARK:- override every possible place where viewControllers change
    public func pushLogicalController(_ logicalController: LogicalController, animated: Bool) {
        self.controllers.append(logicalController)
        self.pushViewController(logicalController.mainVC, animated: animated)
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.controllers.last?.mainVC != viewController {
            self.controllers.append(viewController)
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    public override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        self.controllers = viewControllers
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    public override func show(_ vc: UIViewController, sender: Any?) {
        self.controllers.append(vc)
        super.show(vc, sender: sender)
    }
    
    public override func popViewController(animated: Bool) -> UIViewController? {
        print("pop. vcs count: \(self.viewControllers.count), lcs count: \(self.controllers.count)")
        let poppedController = super.popViewController(animated: animated)
        self.onSuccessfullTransition.append {
            poppedController.map { self.removePoppedVCs([$0]) }
        }
        return poppedController
    }
    
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        print("popTo. vcs count: \(self.viewControllers.count), lcs count: \(self.controllers.count)")
        let poppedControllers = super.popToViewController(viewController, animated: animated)
        self.onSuccessfullTransition.append {
            self.removePoppedVCs(poppedControllers)
        }
        return poppedControllers
    }
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        print("poptoroot. vcs count: \(self.viewControllers.count), lcs count: \(self.controllers.count)")
        let poppedControllers = super.popToRootViewController(animated: animated)
        self.onSuccessfullTransition.append {
            self.removePoppedVCs(poppedControllers)
        }
        return poppedControllers
    }
    
    //MARK:- UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges({ (context) in
                // first, we get here and check if we cancelled transition
                if context.isCancelled {
                    self.onSuccessfullTransition = []
                }
            })
            coordinator.animate(alongsideTransition: { (_) in
                
            }, completion: { (_) in
                // second, we get here and do block (it will be nil if transition is cancelled)
                for block in self.onSuccessfullTransition {
                    block()
                }
                self.onSuccessfullTransition = []
            })
        }
    }
    
    //MARK:- internal FNs
    private func removePoppedVCs(_ poppedControllers: [UIViewController]?) {
        let newControllers = self.controllers.filter { (logicalController) -> Bool in
            let isPopped = poppedControllers?.first(where: { (vc) -> Bool in
                return logicalController.mainVC == vc
            }) != nil
            return !isPopped
        }
        self.controllers = newControllers
    }
}

public extension LogicalController {
    func maybeNavigation() -> GlobalNavigationController? {
        return self.mainVC as? GlobalNavigationController
    }
}
