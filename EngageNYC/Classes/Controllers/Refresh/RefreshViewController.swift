//
//  RefreshViewController.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class RefreshViewController: UIViewController {
    @IBOutlet weak var lblSync: UILabel!
    @IBOutlet weak var syncActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DispatchQueue.main.async {
            self.syncActivityIndicator.scale(factor: 2)
            self.syncActivityIndicator.startAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
         syncActivityIndicator.stopAnimating()
         syncActivityIndicator.hidesWhenStopped = true
    }


}


