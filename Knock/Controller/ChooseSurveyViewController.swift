


import UIKit


struct ChooseSurveyDataStruct
{
    var surveyId : String = ""
    var surveyName : String = ""
    
}


class ChooseSurveyViewController: UIViewController,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    typealias typeCompletionHandler = () -> ()
    var completion : typeCompletionHandler = {}
    
    var completionHandler : ((_ childVC:ChooseSurveyViewController) -> Void)?
    
    
    
    @IBOutlet weak var fullAddressLbl: UILabel!
    @IBOutlet weak var surveyCollectionView: UICollectionView!
    
    var selectedSurveyId:String = ""
    var selectedSurveyName:String = ""
    
    
    var surveyDataArray = [ChooseSurveyDataStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullAddressLbl.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
       
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
      
        NotificationCenter.default.addObserver(self, selector:#selector(ChooseSurveyViewController.UpdateSurveyView), name: NSNotification.Name(rawValue: "UpdateSurveyView"), object:nil
        )
        
        // Do any additional setup after loading the view.
    }
    
  
    
    func UpdateSurveyView(){
        print("UpdateSurveyView")
        
        populateSurveyData()
    }
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateClientView")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        populateSurveyData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        if(SalesforceConnection.surveyId == surveyDataArray[indexPath.row].surveyId){
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
            cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
        }
        else{
            cell.isSelected = false
            cell.backgroundColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1) //gray
            
        }
        cell.surveyName.text = surveyDataArray[indexPath.row].surveyName
        cell.surveyId.text = surveyDataArray[indexPath.row].surveyId
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyCollectionViewCell
        
        currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) // green
        
        
        selectedSurveyId = currentCell.surveyId.text!
        
        selectedSurveyName = currentCell.surveyName.text!
        
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
    
    @IBAction func cancel(_ sender: Any) {
        
        let msgtitle = "Warning"
        
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to cancel without saving?", preferredStyle: .alert)
        alertController.setValue(NSAttributedString(string: msgtitle, attributes: [NSFontAttributeName :  UIFont(name: "Arial", size: 17.0)!, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
        
        
        
        
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
        
        
        
    }
    
    @IBAction func next(_ sender: Any) {
        
        if(Utilities.SurveyOutput.count > 0 ){
            
            let msgtitle = "Message"
            
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to switch survey? Switch to new survey will result to loss of your existing survey data.", preferredStyle: .alert)
            alertController.setValue(NSAttributedString(string: msgtitle, attributes: [NSFontAttributeName :  UIFont(name: "Arial", size: 17.0)!, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
            
            
            
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                
                self.dismiss(animated: true) {
                    
                    SalesforceConnection.surveyId = self.selectedSurveyId
                    
                    SalesforceConnection.surveyName = self.selectedSurveyName
                    
                    self.completionHandler?(self)
                    
                    print("Completion");
                    
                }
            
            }
            alertController.addAction(okAction)
            
            
            self.present(alertController, animated: true, completion: nil)
            

            
        }
            
        else if(SalesforceConnection.surveyId == selectedSurveyId){
            
             self.dismiss(animated: true, completion: nil)
        }
            
        else{
            self.dismiss(animated: true) {
                
                SalesforceConnection.surveyId = self.selectedSurveyId
                
                SalesforceConnection.surveyName = self.selectedSurveyName
                
                self.completionHandler?(self)
                
                print("Completion");
                
            }
        }
    }
    
    func populateSurveyData(){
        
        surveyDataArray = [ChooseSurveyDataStruct]()
        
        let surveyQuestionResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "assignmentId == %@" ,predicateValue: SalesforceConnection.assignmentId,isPredicate:true) as! [SurveyQuestion]
        
        
        if(surveyQuestionResults.count > 0){
            
            for surveyData in surveyQuestionResults{
                
                
                let objectSurveyStruct:ChooseSurveyDataStruct = ChooseSurveyDataStruct(surveyId: surveyData.surveyId!, surveyName: surveyData.surveyName!)
                
                surveyDataArray.append(objectSurveyStruct)
                
            }
        }
        
        selectedSurveyId =  SalesforceConnection.surveyId
        
        
        self.surveyCollectionView.reloadData()
        
        
    }
    
    
    func dismissVCCompletion(completionHandler: @escaping typeCompletionHandler) {
        self.completion = completionHandler
    }
    
}
