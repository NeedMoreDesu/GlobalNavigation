//
//  IHYLVCController.swift
//  IHeardYouLiekViewControllers
//
//  Created by Oleksii Horishnii on 4/18/17.
//  Copyright © 2017 Oleksii Horishnii. All rights reserved.
//

import Foundation

public protocol LogicalController {
    var mainVC: UIViewController { get }
}

public extension LogicalController {
    public func equals(_ second: LogicalController) -> Bool {
        return self.mainVC == second.mainVC
    }
    public func sameClass(_ second: LogicalController) -> Bool {
        return object_getClassName(self) == object_getClassName(second)
    }
}

extension UIViewController: LogicalController {
    public var mainVC: UIViewController {
        return self
    }
}
