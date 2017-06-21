//
//  EditLocationViewController.swift
//  Knock
//
//  Created by Kamal on 16/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import DropDown
import DLRadioButton

class EditLocationViewController: UIViewController {
    
    
    @IBOutlet weak var fullAddressLbl: UILabel!

    @IBOutlet weak var NoOfUnitsTextField: UITextField!
    @IBOutlet weak var NotesTextArea: UITextView!
    
    
    @IBOutlet weak var canvassingStatusDropDown: UIButton!
    
    let chooseStatusDropDown = DropDown()
   
    
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseStatusDropDown
        ]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setupStatusDropDown()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        NotesTextArea.textColor = UIColor.lightGray
        


        // Do any additional setup after loading the view.
    }
    
    func setupStatusDropDown() {
        chooseStatusDropDown.anchorView = canvassingStatusDropDown
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseStatusDropDown.bottomOffset = CGPoint(x: 0, y: canvassingStatusDropDown.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseStatusDropDown.dataSource = [
            "Canvassed",
            "Not Canvassed",
            "Permanently Inaccessible",
            "Temporarily Inaccessible",
            "Incomplete",
            "Address not Found",
            "Not a Target Building",
            "Do not Knock"
        ]
        
        // Action triggered on selection
        chooseStatusDropDown.selectionAction = { [unowned self] (index, item) in
            self.canvassingStatusDropDown.setTitle(item, for: .normal)
        }
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        //		dropDown.selectRowAtIndex(3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseStatus(_ sender: Any) {
        chooseStatusDropDown.show()
    }
    
    
    @IBAction func selectAttempt(_ sender: DLRadioButton) {
    }

    @IBAction func saveLocation(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelLocation(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    
    
//    @IBAction func saveLocation(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func cancelLocation(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
   
}
