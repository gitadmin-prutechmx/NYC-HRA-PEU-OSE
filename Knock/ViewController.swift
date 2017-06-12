//
//  ViewController.swift
//  Knock
//
//  Created by Kamal on 01/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

/*import Alamofire
import Toast_Swift
import RNCryptor
import CryptoSwift
*/

class ViewController: UIViewController {

    var salesforceConfigData = [SalesforceOrgConfig]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromSalesforce()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getDataFromSalesforce(){
       
        var companyName = "PEU"
        var email = "nik@mtxb2b.com"
        
        var emailParams : [String:String] = [:]
        
        //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SalesforceOrgConfig")
        //        fetchRequest.predicate = NSPredicate(format: "companyName = PEU")
        //
        //        do{
        //
        salesforceConfigData = ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig",predicateFormat: "companyName == %@" ,predicateValue: companyName, isPredicate:true) as! [SalesforceOrgConfig]
        
        if(salesforceConfigData.count > 0){
            
            for data in salesforceConfigData{
                
                SalesforceConfig.clientId = data.clientId!
                SalesforceConfig.clientSecret = data.clientSecret!
                SalesforceConfig.hostUrl = data.endPointUrl!
                SalesforceConfig.userName = data.userName!
                SalesforceConfig.password = data.password!

                
            }
            
            
            /*for data in results as! [NSManagedObject]
             {
             
             if let clientId = data.value(forKey: "clientId") as? String{
             
             }
             if let clientSecret = data.value(forKey: "clientSecret") as? String{
             
             }
             
             }
             */
            
            
        }
        else{
            //one time activity
            //Save data
            let configData = SalesforceOrgConfig(context: context)
            configData.companyName = "PEU"
            configData.endPointUrl = "https://nyc-mayorpeu--dev.cs33.my.salesforce.com"
            configData.clientId = "3MVG9Zdl7Yn6QDKMCsJWeIlvKopZ7msQYyL8QxLvD3E8Yd49Gt1N2HApGbrEtOMMU6x9yWuvY20_l5D7Tt0uN"
            configData.clientSecret = "5050630969965231251"
            configData.userName = "nik%2bpeu%40mtxb2b%2Ecom%2Edev"
            configData.password = "peuprutech1234"
            
            appDelegate.saveContext()
            
            //load data
            salesforceConfigData =  ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig",predicateFormat: "companyName == %@" ,predicateValue: companyName, isPredicate:true) as! [SalesforceOrgConfig]
            
            if(salesforceConfigData.count > 0){
                
                for data in salesforceConfigData{
                    
                    SalesforceConfig.clientId = data.clientId!
                    SalesforceConfig.clientSecret = data.clientSecret!
                    SalesforceConfig.hostUrl = data.endPointUrl!
                    SalesforceConfig.userName = data.userName!
                    SalesforceConfig.password = data.password!
                    
                }
            }
            
        }
        
        
        SalesforceConnection.loginToSalesforce(companyName: companyName) { response in
            
            print(response.1!)
            
             let encryptEmailStr = try! email.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            
            
            emailParams["email"] = encryptEmailStr
            
            SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.getAllCanverssorData, params: emailParams){ jsonData in
                
              let decryptData =  Utilities.decryptJsonData(jsonEncryptString: jsonData.1!)
                
              //  decryptData = Utilities.decryptJsonData(json: data!) as NSData?
                
              self.readJSONData(jsonObject: Utilities.convertToJSON(text: decryptData) as! Dictionary<String, AnyObject>)
                
               
                
                
                
            }
            
         
            
         
            
        }
    
        
        
        //        }
        //        catch{
        //
        //        }
        
        // fetchRequest.predicate = NSPredicate(format: "companyName = \(NSNumber(bool:true))")
        //let fetchRequest =  try! context.fetch(SalesforceOrgConfig.fetchRequest())
        
        
        

    }

    
    func readJSONData(jsonObject: Dictionary<String, AnyObject>){
        
        guard let errorMessage = jsonObject["errorMessage"] as? String,
            let results = jsonObject["Event"] as? [[String: AnyObject]] else { return }
        
        for data in results {
         
            print(data)
            /*let event = data["event"] as? String  ?? ""
            let assignment = data["assignmentName"] as? String ?? ""
            let assignmentId = data["assignmentId"] as? String ?? ""
            let totalUnits = data["totalUnits"] as? String ?? ""
            let totalLocations = data["totalLocations"] as? String ?? ""
            let completePercentage =  data["completePercantage"] as? String ?? ""
            */
            
            
            
            
        }

        
    }


}

