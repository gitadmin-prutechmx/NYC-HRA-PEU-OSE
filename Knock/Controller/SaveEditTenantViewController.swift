//
//  SaveEditTenantViewController.swift
//  Knock
//
//  Created by Kamal on 22/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SaveEditTenantViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func save(_ sender: Any) {
       self.navigationController?.popViewController(animated: true);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
