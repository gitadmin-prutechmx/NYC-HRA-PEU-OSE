//
//  AddressInfoViewController.swift
//  EngageNYC
//
//  Created by Kamal on 16/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class AddressInfoViewController: UIViewController,UIPickerViewDelegate,UITextFieldDelegate,UIPickerViewDataSource {

    @IBOutlet weak var streetNumberView: UIView!
    @IBOutlet weak var streetNameView: UIView!
    @IBOutlet weak var boroughView: UIView!
    @IBOutlet weak var zipView: UIView!
    @IBOutlet weak var aptNoView: UIView!
    @IBOutlet weak var aptFloorView: UIView!
    
    @IBOutlet weak var btnAptNumber: UIButton!
    
    @IBOutlet weak var txtStreetNumber: UITextField!
    @IBOutlet weak var txtStreetName: UITextField!
    @IBOutlet weak var txtBorough: UITextField!
    @IBOutlet weak var txtZip: UITextField!
    @IBOutlet weak var txtAptFloor: UITextField!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var rightBarButton: UIButton!
    var boroughPickListArray: [String]!
    let pickerView = UIPickerView()
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var viewModel:AddressInfoViewModel!
    var contactObj:ContactDO!
    var isFromClientIntake:Bool = false
    
    var selectedRow = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnAptNumber.layer.cornerRadius = 7.0
        btnAptNumber.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        btnAptNumber.layer.borderWidth = 1.0
        btnAptNumber.clipsToBounds = true
    
       
        bindView()
        setUpUI()
        if(contactObj != nil){
            populateAddress()
        }
    
       
    }
    
    func populateAddress(){
        txtStreetName.text = contactObj.streetName
        txtStreetNumber.text = contactObj.streetNum
        txtBorough.text = contactObj.borough
        txtZip.text = contactObj.zip
        txtAptFloor.text = contactObj.floor
        btnAptNumber.setTitle(contactObj.aptNo, for: .normal)
    }
    
    
    
    func setUpUI(){
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.showsSelectionIndicator = true
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.tintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        toolBar.barTintColor = UIColor.white
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.donePicker))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style:UIBarButtonItemStyle.plain, target: self, action: #selector(self.canclePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtBorough.inputView = pickerView
        txtBorough.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtBorough.inputAssistantItem.trailingBarButtonGroups.removeAll()
        txtBorough.inputAccessoryView = toolBar
        
        boroughPickListArray =  self.viewModel.getBoroughPicklist(objectType: "Contact", fieldName: "Borough__c")
        
    }
    
    func donePicker()
    {
        txtBorough.text = boroughPickListArray[selectedRow] as? String
        self.contactObj.borough = txtBorough.text!
        txtBorough.resignFirstResponder()
        
    }
    
    func canclePicker()
    {
        txtBorough.resignFirstResponder()
    }
    
    @IBAction func btnLeftBarPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnRightBarPressed(_ sender: Any) {
        
        self.rightBarButton.isEnabled = false
        
        if(contactObj.streetNum.isEmpty){
            //apartmentView.shake()
            self.view.makeToast("Please enter street Number.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.rightBarButton.isEnabled = true
                
                
            }
        }
        else if(contactObj.streetName.isEmpty){
            //apartmentView.shake()
            self.view.makeToast("Please enter street Name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.rightBarButton.isEnabled = true
                
                
            }
        }
        else if(contactObj.borough.isEmpty){
            //apartmentView.shake()
            self.view.makeToast("Please select borough.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.rightBarButton.isEnabled = true
                
                
            }
        }
        else{
            
            if(contactObj.aptNo == virtualUnitName.unknown.rawValue){
                
                let locationUnitTuple = self.viewModel.createVirtualUnit(unitName:contactObj.aptNo,canvasserTaskDataObject:canvasserTaskDataObject)
                contactObj.locationUnitId = locationUnitTuple.locUnitId
                contactObj.assignmentLocUnitId = locationUnitTuple.assignmentLocUnitId
                
            }
            
            self.viewModel.updateContact(objContactDO: contactObj)
            
            self.view.makeToast("Contact has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if(self.isFromClientIntake){
                    
                     //reload intakelisting and redirect canvasser to intake client screen
                    
                    //Notification Center:- reload intakelisting
                    CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.INTAKECLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                    
                   
                    self.performSegue(withIdentifier: "UnwindBackToInTakeIdentifier", sender: self)
                }
               
                
                
                //Notification Center:- reload unitlisting
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                
                //Notification Center:- reload unitlisting
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.CLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    @IBAction func btnAptNoPressed(_ sender: Any) {
        
        
        //get unitlisting
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = btnAptNumber
            popoverContent.popoverPresentationController?.sourceRect = btnAptNumber.bounds
            popoverContent.type = .unitsList
            popoverContent.selectedId = self.contactObj.locationUnitId
            popoverContent.arrList = self.viewModel.getAllLocationUnitsWithoutVirtualUnit(assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId, assignmentLocId: canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId)
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: nil)
        }
        
        
    }
    
    
    @IBAction func btnAddNewUnitPressed(_ sender: Any) {
        
        if let newUnitVC = NewUnitStoryboard().instantiateViewController(withIdentifier: "NewUnitViewController") as? NewUnitViewController
        {
            newUnitVC.canvassserTaskDataObject = canvasserTaskDataObject
            newUnitVC.isFromUnitListing = false
            let completionHandler:(NewUnitViewController)->Void = { newUnitVC in
                
                if let unitName = newUnitVC.txtUnit.text{
                    self.btnAptNumber.setTitle(unitName, for: .normal)
                    
                    self.contactObj.aptNo = unitName
                    self.contactObj.locationUnitId = newUnitVC.locUnitId
                    //self.contactObj.locationUnitId = newUnitVC.
                }
            }
            
            newUnitVC.completionHandler = completionHandler
            newUnitVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(newUnitVC, animated: true)
        }
        
    }

}

extension AddressInfoViewController{
    
    func validate(value: String) -> Bool
    {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  value == filtered
    }
    
    func isValidZipcode(value: String) -> Bool
    {
        
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        
        let currentCharacterCount = txtZip.text?.count ?? 0
        
        let newLength = currentCharacterCount + value.count
        if(newLength > 9)
        {
            self.contactObj.streetNum = txtZip.text!
            return false
        }
        
        self.contactObj.zip = value
        
        return value == filtered
        
        
    }
    
    func isValidFloor(value:String) -> Bool
    {
        
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        
        let currentCharacterCount = txtAptFloor.text?.count ?? 0
        
        let newLength = currentCharacterCount + value.count
        if(newLength > 3)
        {
            self.contactObj.floor = txtAptFloor.text!
            return false
        }
        
        self.contactObj.floor = value
        
        return value == filtered
        
    }
    
    func isValidStreetNum(value:String) -> Bool
    {
         let charcterSet  = NSCharacterSet(charactersIn: "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        
        let currentCharacterCount = txtStreetNumber.text?.count ?? 0
        
        let newLength = currentCharacterCount + value.count
        if(newLength > 23)
        {
            self.contactObj.streetNum = txtStreetNumber.text!
            return false
        }
        
        self.contactObj.streetNum = value
        return value == filtered
        
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if textField == txtStreetName
        {
            
            guard let text = txtStreetName.text else { return true }
            
            
            let newLength = text.count + string.count - range.length
            if(newLength > 100){
                self.contactObj.streetName = txtStreetName.text!
                return false
            }
            
            self.contactObj.streetName = str
            return true
        }
            
        else if (textField == txtZip)
        {
            return isValidZipcode(value: str)
        }
            
        else if (textField == txtAptFloor)
        {
            return isValidFloor(value: str)
        }
        else if (textField == txtStreetNumber)
        {
            return isValidStreetNum(value: str)
        }
        else
        {
            return validate(value: str)
        }
        
    }
    
}

extension AddressInfoViewController{
    
    //Mark Pickerview delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        return self.boroughPickListArray.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return boroughPickListArray[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
        
    }
    
    
}
    
extension AddressInfoViewController{
    func bindView(){
            self.viewModel = AddressInfoViewModel.getViewModel()
    }
}

extension AddressInfoViewController : ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        btnAptNumber.setTitle(obj.name, for: .normal)
        self.contactObj.aptNo = obj.name
        self.contactObj.locationUnitId = obj.id
        self.contactObj.assignmentLocUnitId = obj.additionalId
    }
}

