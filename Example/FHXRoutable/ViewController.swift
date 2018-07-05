//
//  ViewController.swift
//  FHXRoutable
//
//  Created by fenghanxu on 07/05/2018.
//  Copyright (c) 2018 fenghanxu. All rights reserved.
//

import UIKit
import FHXRoutable
import FHXKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
      let vc = Routable.viewController(str: "sp://greenVC/greenVC")
      sp.push(vc: vc)
    }

  

}

