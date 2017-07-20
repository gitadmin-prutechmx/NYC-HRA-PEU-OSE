//
//  SettingsTableViewController.swift
//  Knock
//
//  Created by Kamal on 12/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController
{
    var dpShowDateVisible = false
    @IBOutlet weak var syncTimeView: UIView!
    @IBOutlet weak var syncTimeLbl: UILabel!
    @IBOutlet weak var dpShowDate: UIDatePicker!
    @IBOutlet weak var TimeLbl: UILabel!
    
    @IBOutlet weak var btnShowTime: UIButton!
 
    @IBOutlet weak var syncTimePickerView: UIView!
    @IBOutlet weak var syncDateView: UIView!
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        syncTimeView.layer.cornerRadius = 5
        
        tableView.allowsSelection = true

        if self.revealViewController() != nil
        {
            
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //self.navigationController?.navigationBarHidden = false
      //  self.StyleNavBar()
        
    }
    
    
    //MARK:- Navigation Bar Method
    
    func StyleNavBar()
    {
        self.navigationController?.isNavigationBarHidden = true
        let newNavBar = UINavigationBar (frame: CGRect(x: 0.0, y: 0.0, width:self.view.bounds.width, height: 64.0))
        
        newNavBar.barStyle = UIBarStyle.black
        newNavBar.tintColor = UIColor.white
        newNavBar.barTintColor =  UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x:0, y:20.0, width:self.view.frame.size.width, height:40))
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.init(name: "System", size: 18.0)
        let newBackbtn = UIButton (frame: CGRect(x:4.0, y: 28.0, width: 30, height: 20))
        
        newBackbtn.setImage(UIImage.init(named: "menu"), for:UIControlState.normal)
        
        if revealViewController() != nil
        {
            
//            newBackbtn.target = self.revealViewController()
//            newBackbtn.action = #selector(SWRevealViewController.revealToggle(_:))

            newBackbtn.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            
        }
        
       
        
        newNavBar.addSubview(titleLabel)
        newNavBar .addSubview(newBackbtn)
        
        self.view .addSubview(newNavBar)
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleShowDateDatepicker ()
    {
        dpShowDateVisible = !dpShowDateVisible
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 1
        {
            if  indexPath.row == 0
            {
                toggleShowDateDatepicker()
                dpShowDateChanged()
            }
            
        }
        
    
        //tableView.deselectRow(at: indexPath as IndexPath, animated: true)
       
//        if indexPath.row == 1
//        {
//            toggleShowDateDatepicker()
//        }
//        
//        
//
    }
    
    func tableView(tableView:UITableView,heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !dpShowDateVisible && indexPath.row == 1
        {
            return 0
        }
        else {
            return 44
        }
    }
    
    func dpShowDateChanged ()
    {
        TimeLbl.text = DateFormatter.localizedString(from: dpShowDate.date, dateStyle:.none, timeStyle: .short)
        
    }


    @IBAction func syncTimeSlider(_ sender: UISlider) {
        
        let currentValue = Int(sender.value)
        syncTimeLbl.text = "\(currentValue)"
    }
  
    @IBAction func dpShowTimeAction(_ sender: Any)
    {
         dpShowDateChanged()
    }
    
    @IBAction func cancel(_ sender: Any) {
        let alertController = UIAlertController(title: "Message", message: "Are you sure you want to cancel without saving", preferredStyle: .alert)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertController.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            
            
            self.dismiss(animated: true, completion: nil)
            //Do some other stuff
        }
        alertController.addAction(okAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
      
       // self.navigationController!.popViewController(animated: true)
    }

    @IBAction func save(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
       // self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func btnShowTimeAction(_ sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            syncTimePickerView.isHidden = true
        }
        else
        {
            syncTimePickerView.isHidden = false
        }
        
    }
    

}
