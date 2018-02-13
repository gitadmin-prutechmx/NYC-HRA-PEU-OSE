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
    var eventStaffLeadId:String!
    var eventStaffLeadName:String!
    
    init(){
        id = ""
        name = ""
        type = ""
        date = ""
        startTime = ""
        endTime = ""
        address = ""
        eventStaffLeadId = ""
        eventStaffLeadName = ""
    }

}

class  EventsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
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
    
    @IBOutlet weak var lblEvents: UILabel!
    
    @IBOutlet weak var rightBarButton: UIButton!
    var fromDate: Date!
    var toDate: Date!
    var strType: String!
    var isFromSurveyScreen:Bool!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    var viewModel: EventsViewModel!
    var arrEventsMain = [EventDO]()
    var arrFilter = [EventDO]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setUpUI()
        self.setupView()
        fromDate = Date()
        toDate = Date()
        
        Utility.makeButtonBorder(btn: rightBarButton)
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
            self.strType = self.btnType.titleLabel?.text
            self.arrEventsMain = self.viewModel.loadEvents()
            self.arrFilter = self.arrEventsMain
            
            self.lblEvents.text = "EVENTS (\(self.arrEventsMain.count))"
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
    
    
    @IBAction func btnFilterPress(_ sender: Any)
    {
        
        if validation()
        {
            if strType != "Type" {
                self.arrEventsMain = self.arrFilter.filter({ (event) -> Bool in
                    return (event.type == strType)
                })
                
                if lblFromDate.text != "From" && lblToDate.text != "To" {
                    self.arrEventsMain = self.arrEventsMain.filter { (event) -> Bool in
                        
                        return isDateFallInFilterDateRange(event: event)
                    }
                }
            }
            else
            {
                self.arrEventsMain = self.arrFilter.filter { (event) -> Bool in
                    
                    return isDateFallInFilterDateRange(event: event)
                }
            }
            
        }
        
         self.lblEvents.text = "EVENTS (\(self.arrEventsMain.count))"
        
        tblEvents.reloadData()
    }
    
    func isDateFallInFilterDateRange(event: EventDO) -> Bool {
        let dFor = DateFormatter()
        dFor.dateFormat = "yyyy-MM-dd"
        let eventDate = dFor.date(from: event.date!)
        if (fromDate?.compare(eventDate!) == .orderedAscending || fromDate?.compare(eventDate!) == .orderedSame) && (toDate?.compare(eventDate!) == .orderedDescending || toDate?.compare(eventDate!) == .orderedSame) {
            return true
        } else {
            return false
        }
    }
   
    func compareFromToDate() -> Bool {
        if toDate.compare(fromDate!) == .orderedAscending {
            return true
        }
        return false
    }
    
    func validation() -> Bool
    {
        if lblFromDate.text == "From" && lblToDate.text == "To" && btnType.titleLabel?.text == "Type"
        {
            self.view.makeToast("Please select any filter", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            }
            return false
        }
        
        else if btnType.titleLabel?.text != "Type" && lblFromDate.text == "From" && lblToDate.text == "To"
        {
            return true
        }
        else if lblFromDate.text == "From"
        {
            self.view.makeToast("Please select FromDate", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
           return false
        }
        else if lblToDate.text == "To"
        {
            self.view.makeToast("Please select ToDate", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
            return false
            
        }
        else if compareFromToDate()
        {
            self.view.makeToast("ToDate must be greater than FromDate", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
            return false
        }
        return true
    }
    
    @IBAction func btnTypeClick(_ sender: Any)
    {
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = self.btnType
            popoverContent.popoverPresentationController?.sourceRect = self.btnType.bounds
            popoverContent.selectedId = self.btnType.titleLabel?.text
            popoverContent.arrList = self.viewModel.getEventsTypeicklist(objectType: "Event__c", fieldName: "Event_Type__c")
            popoverContent.type = .eventsType
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnResetClick(_ sender: Any)
    {
        lblFromDate.text = "From"
        lblToDate.text = "To"
        btnType.setTitle("Type", for: .normal)
        strType = btnType.titleLabel?.text
        self.arrEventsMain = self.arrFilter
        fromDate = Date()
        toDate = Date()
        
        self.lblEvents.text = "EVENTS (\(self.arrEventsMain.count))"
        
        tblEvents.reloadData()
    }
    
    @IBAction func btnFromDateClick(_ sender: Any) {
        
        if let popoverContent = DatePickerListingPopOverStoryboard().instantiateViewController(withIdentifier: "DatePickerListingPopOver") as? DatePickerListingPopOver{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = self.btnFrom
            popoverContent.popoverPresentationController?.sourceRect = self.btnFrom.bounds
            popoverContent.pickeType = DateTimePickerType.from
            
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: {
                popoverContent.datePicker.date = self.fromDate
            })
           
        }
        
    }
    @IBAction func btnToDateClick(_ sender: Any) {
        
        if let popoverContent = DatePickerListingPopOverStoryboard().instantiateViewController(withIdentifier: "DatePickerListingPopOver") as? DatePickerListingPopOver{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = self.btnTo
            popoverContent.popoverPresentationController?.sourceRect = self.btnTo.bounds
            popoverContent.pickeType = DateTimePickerType.to
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: {
                popoverContent.datePicker.date = self.toDate
            })
          
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
        dateformter.dateFormat = "yyyy-MM-dd"//"MM-dd-yyyy"
        
        switch forType {
        case .from:
            lblFromDate.text = dateformter.string(from: selectedDate)
            fromDate = selectedDate
            break
        case .to: 
            lblToDate.text = dateformter.string(from: selectedDate)
            toDate = selectedDate
            break
        }
    }
}



extension EventsViewController : ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        btnType.setTitle(obj.name, for: .normal)
        if let buttonTitle = btnType.title(for: .normal) {
            strType = buttonTitle
            print(buttonTitle)
        }
        
    }
}
