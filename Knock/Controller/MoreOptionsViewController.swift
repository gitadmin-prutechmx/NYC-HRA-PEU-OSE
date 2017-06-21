//
//  MoreOptionsViewController.swift
//  Knock
//
//  Created by Kamal on 19/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

struct SurveyDataStruct
{
    var surveyId : String = ""
    var surveyName : String = ""
    
}


class MoreOptionsViewController: UIViewController,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
   
    @IBOutlet weak var chooseSurveyView: UIView!
    
    @IBOutlet weak var surveyCollectionView: UICollectionView!
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var fullAddressText: UILabel!
    
    
    var surveyDataArray = [SurveyDataStruct]()
    var selectedSurveyId:String = ""
    
    var surveyUnitResults = [SurveyUnit]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullAddressText.text = "59 Wooster St, New York, NY 10012"// SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        populateSurveyData()
        
        if(Utilities.currentSegmentedControl == "Unit"){
            segmentedControl.selectedSegmentIndex = 0
            
            chooseSurveyView.isHidden = true
        }
        else if(Utilities.currentSegmentedControl == "Tenant"){
            segmentedControl.selectedSegmentIndex = 1
            
            chooseSurveyView.isHidden = true
        }
        else if(Utilities.currentSegmentedControl == "Survey"){
            segmentedControl.selectedSegmentIndex = 2
            
            chooseSurveyView.isHidden = false
            
            surveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyUnit",predicateFormat: "unitId == %@" ,predicateValue: SalesforceConnection.unitId,isPredicate:true) as! [SurveyUnit]
            
            if(surveyUnitResults.count == 1){
                selectedSurveyId = surveyUnitResults[0].surveyId!
            }
            else{
                selectedSurveyId = ""
            }
            
            
            
           
        }

        // Do any additional setup after loading the view.
    }
    
    
    func populateSurveyData(){
        
        //let unitResults = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "locationId == %@" ,predicateValue: SalesforceConnection.locationId,isPredicate:true) as! [Unit]
        
        let surveyQuestionResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "assignmentId == %@" ,predicateValue: SalesforceConnection.assignmentId,isPredicate:true) as! [SurveyQuestion]
        
        
        if(surveyQuestionResults.count > 0){
            
            for surveyData in surveyQuestionResults{
                
               
                let objectSurveyStruct:SurveyDataStruct = SurveyDataStruct(surveyId: surveyData.surveyId!, surveyName: surveyData.surveyName!)
                
                surveyDataArray.append(objectSurveyStruct)
                
            }
        }
        
       
         self.surveyCollectionView.reloadData()
        
        
        /*
         DispatchQueue.global(qos: .background).async {
         print("This is run on the background queue")
         
         DispatchQueue.main.async {
         print("This is run on the main queue, after the previous code in outer block")
         }
         }
         
         */
        
        
        
        
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeSegmented(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
             chooseSurveyView.isHidden = true
        case 1:
             chooseSurveyView.isHidden = true
        case 2:
             chooseSurveyView.isHidden = false
        default:
            chooseSurveyView.isHidden = false
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
  if(Utilities.currentSegmentedControl == "Survey"){
            
    
        
        //update or delete particular surveyunit
        //add multiple conditions in predicateformat
        
        if(surveyUnitResults.count == 0){
            
            //save the record
            let surveyUnitObject = SurveyUnit(context: context)
            surveyUnitObject.assignmentId = SalesforceConnection.assignmentId
            surveyUnitObject.surveyId = selectedSurveyId
            surveyUnitObject.unitId = SalesforceConnection.unitId
            
            
            
            appDelegate.saveContext()
            
            
            self.view.makeToast("Changes has been done successfully", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
            
        }
        else{
            
            //update
             ManageCoreData.updateData(salesforceEntityName: "SurveyUnit", valueToBeUpdate: selectedSurveyId,updatekey:"surveyId", predicateFormat: "unitId == %@", predicateValue: SalesforceConnection.unitId, isPredicate: true)
            
        }
    }
        
  }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveyDataArray.count
        //return 4
    }
    

    
    var widthToUse : CGFloat?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        surveyCollectionView.reloadData()
        
        widthToUse = size.width - 40
        
        let collectionViewLayout = surveyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.invalidateLayout()
        
        //self.optionsCollectionView?
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SurveyCollectionViewCell
        
        if(selectedSurveyId == surveyDataArray[indexPath.row].surveyId){
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
            cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
        }
        
        cell.surveyName.text = surveyDataArray[indexPath.row].surveyName
        cell.surveyId.text = surveyDataArray[indexPath.row].surveyId
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyCollectionViewCell
        
        currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) // green
        
        
       selectedSurveyId = currentCell.surveyId.text!
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyCollectionViewCell
        
        currentCell.backgroundColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1) //gray
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        
        var collectionViewWidth = collectionView.bounds.width
        
        if let w = widthToUse
        {
            collectionViewWidth = w
        }
        
        let width = collectionViewWidth - collectionViewLayout!.sectionInset.left - collectionViewLayout!.sectionInset.right
        
        //let width = -170
        
        return CGSize(width: width, height:50)
        
    }


    

}
