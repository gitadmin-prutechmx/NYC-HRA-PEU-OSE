//
//  EventsViewController.swift
//  EngageNYCDev
//
//  Created by MTX on 1/3/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class EventDO{
    var id:String!
    var name:String!
    var type:String!
    var date:String!
    var startTime:String!
    var endTime:String!
    var address:String!
    var eventsDynamic:NSObject!

}

class EventsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
   
    var strSelected:String!
    @IBOutlet weak var lblToDate: UILabel!
    @IBOutlet weak var lblFromDate: UILabel!
    @IBOutlet weak var tblEvents: UITableView!
    @IBOutlet weak var btnFrom: UIButton!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnTo: UIButton!
    @IBOutlet weak var imgBtnTo: UIImageView!
    @IBOutlet weak var imgBtnFrom: UIImageView!
    
    var isFromSurveyScreen:Bool!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    var viewModel: EventsViewModel!
    var arrEventsMain = [EventDO]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setUpUI()
        self.setupView()
    }
    
    
    func setUpUI(){
        
        btnType.layer.borderWidth = 2.0
        btnType.layer.borderColor =  UIColor(red:93.0/255.0, green:85.0/255.0, blue:75.0/255.0, alpha: 1.0).cgColor
        btnType.clipsToBounds = true
        
        imgBtnTo.image = imgBtnTo.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imgBtnTo.tintColor = UIColor.lightGray
        
        imgBtnFrom.image = imgBtnFrom.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imgBtnFrom.tintColor = UIColor.lightGray
    }
    
    func setupView() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){
        
         DispatchQueue.main.async {
            self.arrEventsMain = self.viewModel.loadEvents()
            self.tblEvents.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true;
        self.reloadView()
    }
    
    @IBAction func cancel(_ sender: Any) {
        
      self.dismiss(animated: true, completion: nil)
  
    }
    
    @IBAction func btnTypeClick(_ sender: Any)
    {
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = self.btnType
            popoverContent.popoverPresentationController?.sourceRect = self.btnType.bounds
            popoverContent.type = .eventsType
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnResetClick(_ sender: Any) {
    }
    
    @IBAction func btnFromDateClick(_ sender: Any) {
        
        if let popoverContent = DatePickerListingPopOverStoryboard().instantiateViewController(withIdentifier: "DatePickerListingPopOver") as? DatePickerListingPopOver{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = self.btnFrom
            popoverContent.popoverPresentationController?.sourceRect = self.btnFrom.bounds
            popoverContent.pickeType = DateTimePickerType.from
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: nil)
        }
        
    }
    @IBAction func btnToDateClick(_ sender: Any) {
        
        if let popoverContent = DatePickerListingPopOverStoryboard().instantiateViewController(withIdentifier: "DatePickerListingPopOver") as? DatePickerListingPopOver{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = self.btnTo
            popoverContent.popoverPresentationController?.sourceRect = self.btnTo.bounds
            popoverContent.pickeType = DateTimePickerType.to
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: nil)
        }
    }

    
    
}


extension EventsViewController {
    
    func bindView() {
        self.viewModel = EventsViewModel.getViewModel()
        
    }
}


extension EventsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEventsMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:EventsTableViewCell = self.tblEvents.dequeueReusableCell(withIdentifier: "eventCell") as! EventsTableViewCell!
        
        if(arrEventsMain.count > 0){
            
            cell.setupView(forCellObject:arrEventsMain[indexPath.row],index:indexPath)
        }
        return cell
     
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let eventDrillDown = EventsDrillDownStoryboard().instantiateViewController(withIdentifier: "EventsDrillDownViewController") as? EventsDrillDownViewController
        {
            eventDrillDown.isFromSurveyScreen = self.isFromSurveyScreen
            eventDrillDown.canvasserTaskDataObject = self.canvasserTaskDataObject
            
            eventDrillDown.objEvent =  arrEventsMain[indexPath.row]
            eventDrillDown.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(eventDrillDown, animated: true)
        }
    }
}

extension EventsViewController: UpdateSelectedDateDelegate
{
    func didSelectDate(selectedDate :Date, forType: DateTimePickerType)
    {
        let dateformter = DateFormatter()
        dateformter.dateFormat = "MM/dd/yyyy"
        switch forType {
        case .from:
            lblFromDate.text = dateformter.string(from: selectedDate)
            break
        case .to: 
            lblToDate.text = dateformter.string(from: selectedDate)
            break
        }
    }
}

extension EventsViewController : ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
         btnType.setTitle(obj.name, for: .normal)
    }
}
