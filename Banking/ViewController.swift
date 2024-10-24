//
//  ViewController.swift
//  Banking
//
//  Created by Yueyang Ding on 2024-10-24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Example usage inside a function
        let ethereumAddress = "0x0000000000000000000000000000000000000000"  // Example Ethereum address
        
        // Create a SwiftUI view with the dynamic Ethereum address
        let firstView = FirstView()
        
        // Hosting the SwiftUI view inside the UIKit ViewController
        let hostingController = UIHostingController(rootView: firstView)
        addChild(hostingController)
        hostingController.view.frame = self.view.frame
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
