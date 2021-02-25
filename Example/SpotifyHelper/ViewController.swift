//
//  ViewController.swift
//  SpotifyHelper_Example
//
//  Created by Balázs Morvay on 2021. 02. 22..
//  Copyright © 2021. CocoaPods. All rights reserved.
//

import UIKit

class ViewController: UINavigationController {
    
    var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button = UIButton(frame: self.view.frame)
        button.addTarget(self, action: #selector(ehh), for: .touchUpInside)
        button.setTitle("Show", for: .normal)
        button.backgroundColor = .white
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(button)
        
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let myVC = SpotifyViewController(nibName: "SpotifyViewController", bundle: nil)
        myVC.setParentVC(vc: self)
        self.present(myVC, animated: true)
        

        // Do any additional setup after loading the view.
    }
    
    @objc func ehh() {
        let myVC = SpotifyViewController(nibName: "SpotifyViewController", bundle: nil)
        myVC.setParentVC(vc: self)
        self.present(myVC, animated: false)
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
