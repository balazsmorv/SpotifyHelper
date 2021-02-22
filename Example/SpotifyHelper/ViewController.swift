//
//  ViewController.swift
//  SpotifyHelper_Example
//
//  Created by Balázs Morvay on 2021. 02. 22..
//  Copyright © 2021. CocoaPods. All rights reserved.
//

import UIKit

class ViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myVC = SpotifyViewController(nibName: "SpotifyViewController", bundle: nil)
        self.pushViewController(myVC, animated: true)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
