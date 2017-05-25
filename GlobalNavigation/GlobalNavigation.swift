//
//  GlobalNavigation.swift
//  NavSomething
//
//  Created by Oleksii Horishnii on 5/25/17.
//  Copyright © 2017 Oleksii Horishnii. All rights reserved.
//

import Foundation

public class GlobalNavigation {
    public static let shared = GlobalNavigation()
    
    //MARK:- stored data
    private(set) lazy var window: UIWindow = UIWindow()
    public private(set) var modalRoots: [LogicalController] = []
    
    //MARK:- computable variables
    public var currentModalRoot: LogicalController? {
        return self.modalRoots.last
    }
    public var currentModalLine: [LogicalController]? {
        return self.currentModalRoot?.childLogicalControllers()
    }
    public var currentLastLC: LogicalController? {
        return self.currentModalLine?.last
    }
    public var currentNavigationController: GlobalNavigationController? {
        let reversed = self.currentModalLine?.reversed()
        let navigationController = reversed?.first(where: { (controller) -> Bool in
            controller.maybeNavigation() != nil
        })
        return navigationController?.maybeNavigation()
    }
    
    //MARK:- actions
    public indirect enum NavigationType {
        case root
        case push(animated: Bool, completion: (() -> Void)?)
        case modally(animated: Bool, completion: (() -> Void)?)
        case withNavigationSetup(NavigationType)
    }
    public func navigate(_ type: NavigationType, logicalController: LogicalController) {
        switch type {
        case .root:
            self.modalRoots = [logicalController]
            self.window.rootViewController = logicalController.mainVC
            self.window.makeKeyAndVisible()
        case .withNavigationSetup(let type):
            let navigationController = GlobalNavigationController(rootViewController: logicalController)
            self.navigate(type, logicalController: navigationController)
        case .push(let animated, let completion):
            if let navigationController = self.currentNavigationController {
                CATransaction.begin()
                CATransaction.setCompletionBlock(completion)
                navigationController.pushLogicalController(logicalController, animated: animated)
                CATransaction.commit()
            } else {
                self.navigate(.withNavigationSetup(.modally(animated: animated, completion: completion)), logicalController: logicalController)
            }
        case .modally(let animated, let completion):
            if let currentRoot = self.currentModalRoot {
                self.modalRoots.append(logicalController)
                currentRoot.mainVC.present(logicalController.mainVC, animated: animated, completion: completion)
            } else {
                self.navigate(.root, logicalController: logicalController)
            }
        }
    }
    public enum BackNavigationType {
        case pop(animated: Bool, completion: (() -> Void)?)
        case popToRoot(animated: Bool, completion: (() -> Void)?)
        case modally(animated: Bool, completion: (() -> Void)?)
    }
    public func back(_ type: BackNavigationType) {
        switch type {
        case .pop(let animated, let completion):
            if let navigationController = self.currentNavigationController {
                CATransaction.begin()
                CATransaction.setCompletionBlock(completion)
                let _ = navigationController.popViewController(animated: animated)
                CATransaction.commit()
            } else {
                completion?()
            }
        case .popToRoot(let animated, let completion):
            if let navigationController = self.currentNavigationController {
                CATransaction.begin()
                CATransaction.setCompletionBlock(completion)
                let _ = navigationController.popToRootViewController(animated: animated)
                CATransaction.commit()
            } else {
                completion?()
            }
        case .modally(let animated, let completion):
            if let currentRoot = self.currentModalRoot {
                if self.modalRoots.count > 1 {
                    self.modalRoots.removeLast()
                }
                currentRoot.mainVC.dismiss(animated: animated, completion: completion)
            } else {
                completion?()
            }
        }
    }
    
    //MARK:- debug level functions
    public func debugShowBigPicture() -> String {
        let modalRoots = GlobalNavigation.shared.modalRoots
        let lineStrings = modalRoots.map { root -> String in
            let line = root.childLogicalControllers()
            let lineChars = line.map({ (lc) -> String in
                if lc.maybeNavigation() != nil {
                    return "NC"
                } else {
                    return "LC"
                }
            })
            let lineString = lineChars.joined(separator: " → ")
            return lineString
        }
        let navigationPictureString = lineStrings.joined(separator: "\n↓\n")
        return navigationPictureString
    }
}

public extension LogicalController {
    func childLogicalControllers() -> [LogicalController] {
        if let navVC = self.maybeNavigation() {
            var butlast = navVC.controllers
            let last = butlast.popLast()
            let lastLCs = last?.childLogicalControllers() ?? []
            return [self] + butlast + lastLCs
        } else {
            return [self]
        }
    }
    public func navigate(_ type: GlobalNavigation.NavigationType, globalNavigation: GlobalNavigation = .shared) {
        globalNavigation.navigate(type, logicalController: self)
    }
}
