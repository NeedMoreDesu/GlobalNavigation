//
//  ViewController.swift
//  NavSomething
//
//  Created by Oleksii Horishnii on 5/25/17.
//  Copyright © 2017 Oleksii Horishnii. All rights reserved.
//

import UIKit
import GlobalNavigation

class ViewController: UIViewController {
    //MARK: creation
    class func createVC() -> ViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as! ViewController
    }
    //MARK:- lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }
    
    //MARK:- outlets
    @IBOutlet weak var textView: UITextView!
    
    //MARK:- UI
    func updateUI() {
        self.textView.text = GlobalNavigation.shared.debugShowBigPicture()
    }
    
    //MARK:- actions
    @IBAction func rootClicked(_ sender: Any) {
        ViewController.createVC().navigate(.root)
    }
    @IBAction func rootNavigateClicked(_ sender: Any) {
        ViewController.createVC().navigate(.withNavigationSetup(.root))
    }
    @IBAction func pushClicked(_ sender: Any) {
        ViewController.createVC().navigate(.push(animated: true, completion: nil))
    }
    @IBAction func modallyClicked(_ sender: Any) {
        ViewController.createVC().navigate(.modally(animated: true, completion: nil))
    }
    @IBAction func modallyWithNavigationSetup(_ sender: Any) {
        ViewController.createVC().navigate(.withNavigationSetup(.modally(animated: true, completion: nil)))
    }
    @IBAction func popClicked(_ sender: Any) {
        GlobalNavigation.shared.back(.pop(animated: true, completion: nil))
    }
    @IBAction func popToRootClicked(_ sender: Any) {
        GlobalNavigation.shared.back(.popToRoot(animated: true, completion: nil))
    }
    @IBAction func dismissClicked(_ sender: Any) {
        GlobalNavigation.shared.back(.modally(animated: true, completion: nil))
    }
}

