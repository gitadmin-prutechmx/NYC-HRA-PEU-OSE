//
//  SalesforceConnection.swift
//  Knock
//
//  Created by Kamal on 12/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class SalesforceConnection{
    
    
    static var assignmentId:String = ""
    static var locationId:String = ""
    static var fullAddress:String = ""
   
        
 
    private static var salesforceAccessToken:String=""
    
    
    typealias AccessTokenCompletion = (_ succeeded: Bool, _ jsonData: Dictionary<String, AnyObject>) -> Void
    
    //Refresh token handle
    
    
    
    static func loginToSalesforce(companyName:String , completion: @escaping (Bool) -> ()) {
        
        
        let loginUrl: String = SalesforceConfig.hostUrl + "/services/oauth2/token?grant_type=password&client_id=\(SalesforceConfig.clientId)&client_secret=\(SalesforceConfig.clientSecret)&username=\(SalesforceConfig.userName)&password=\(SalesforceConfig.password)"
        
        
        let url = URL(string: loginUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        
        
        Alamofire.request(urlRequest).validate().responseJSON{ response in
            switch response.result {
            case .success:
                if  let json = response.result.value as? [String: Any],
                    let accessToken = json["access_token"] as? String
                {
                 
                    //update accessToken
                    ManageCoreData.updateData(salesforceEntityName: "SalesforceOrgConfig", accessToken: accessToken, predicateFormat: "companyName == %@", predicateValue: companyName, isPredicate: true)
                    
                    
                    salesforceAccessToken = accessToken
                    completion(true)
                } else {
                    completion(false)
                }
                
            case .failure(let error):
                showErrorMessage(error: error as NSError)
                //print(error.localizedDescription)
                completion(false)
                
            }
        }
        
        
    }//end of loginToSalesforce
    

    
    
    static func SalesforceData(restApiUrl:String, params:[String:String]? = nil, completion: @escaping AccessTokenCompletion) {
        
        
//        let baseURLString = "https://some.domain-behind-oauth2.com"
//        
//        let oauthHandler = OAuth2Handler(
//            clientID: "12345678",
//            baseURLString: baseURLString,
//            accessToken: "abcd1234",
//            refreshToken: "ef56789a"
//        )
        
//        let sessionManager = SessionManager()
//        sessionManager.adapter = oauthHandler
//        sessionManager.retrier = oauthHandler
//        
//        let urlString = "\(baseURLString)/some/endpoint"
//        
//        sessionManager.request(urlString).validate().responseJSON { response in
//            debugPrint(response)
//        }

        
        
        
        let url = URL(string: SalesforceConfig.hostUrl + restApiUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params!, options: [])
        } catch {
            // No-op
        }
        
        urlRequest.setValue("OAuth \(salesforceAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        
        Alamofire.request(urlRequest).validate().responseString{ response in
            switch response.result {
                
            case .success:
                    let decryptData =  Utilities.decryptJsonData(jsonEncryptString: response.result.value!)
                    let jsonData = Utilities.convertToJSON(text: decryptData)
                    completion(true, jsonData as! Dictionary<String, AnyObject>)
                
            case .failure(let error):
                
                showErrorMessage(error: error as NSError)
                return

                
            }
        }
        
        
    }//end of loginToSalesforce

    
    
    static func showErrorMessage(error:NSError){
        SVProgressHUD.dismiss()
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    
}
