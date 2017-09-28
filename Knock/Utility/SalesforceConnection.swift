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
    
    
    
    static var salesforceUserId:String = ""
    
    static var assignmentId:String = ""
    static var assignmentName:String = ""
    
    static var locationId:String = ""
    static var assignmentLocationId:String = ""
    
    static var unitId:String = ""
    static var isPrivateHome:String = ""
    static var assignmentLocationUnitId:String = ""
    
    static var currentTenantId:String =  ""
    static var currentTenantName:String = ""
    
    static var isNewContactWithAddress:Bool = false
    
    static var selectedTenantForSurvey:String = ""
    
    static var unitName:String = ""
    static var surveyId:String = ""
    static var surveyName:String = ""
    
    static var fullAddress:String = ""
    
    static var caseId:String = ""
    static var caseNumber:String = ""
    static var dateOfIntake:String = ""
    static var caseStatus:String = ""
    static var caseOwnerId:String = ""
    
    static var currentIssueId:String = ""
 
    
    
    
    
    
    private static var salesforceAccessToken:String=""
    
    
    
    
    typealias AccessTokenCompletion = (_ succeeded: Bool, _ jsonData: Dictionary<String, AnyObject>) -> Void
    
    //Refresh token handle
    
    
    
    static func loginToSalesforce(completion: @escaping (Bool) -> ()) {
        
        
        let loginUrl: String = SalesforceConfig.hostUrl + "/services/oauth2/token?grant_type=password&client_id=\(SalesforceConfig.clientId)&client_secret=\(SalesforceConfig.clientSecret)&username=\(SalesforceConfig.userName)&password=\(SalesforceConfig.password)"
        
        
        let url = URL(string: loginUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        
        
        Alamofire.request(urlRequest).validate().responseJSON{ response in
            switch response.result {
            case .success:
                if  let json = response.result.value as? [String: Any],
                    let accessToken = json["access_token"] as? String,
                    let userId = json["id"] as? String
                {
                    
                    //update accessToken
                    //                    ManageCoreData.updateData(salesforceEntityName: "SalesforceOrgConfig", valueToBeUpdate: accessToken,updatekey:"accessToken", predicateFormat: "companyName == %@", predicateValue: companyName, isPredicate: true)
                    //
                    //
                    salesforceAccessToken = accessToken
                    
                    salesforceUserId = userId.components(separatedBy: "/")[5]
                    
                    completion(true)
                } else {
                    completion(false)
                }
                
            case .failure(let error):
                Utilities.isRefreshBtnClick = false
                print(loginUrl)
                showLoginErrorMessage(error: error as NSError)
                //print(error.localizedDescription)
                completion(false)
                
            }
        }
        
        
    }//end of loginToSalesforce
    
    
    
    
    static func SalesforceData(restApiUrl:String, params:[String:String]? = nil, methodType:String? = "POST" ,completion: @escaping AccessTokenCompletion) {
        
        
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
        
        if(methodType == "POST"){
            urlRequest.httpMethod = "POST"
            
            
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params!, options: [])
            } catch {
                
            }
        }
        else{
            urlRequest.httpMethod = "GET"
        }
        
        urlRequest.setValue("OAuth \(salesforceAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        
        Alamofire.request(urlRequest).validate().responseJSON{ response in
            switch response.result {
                
            case .success:
                if response.result.value != nil {
                    
                    completion(true, response.result.value as! Dictionary<String, AnyObject>)
                }
//                let decryptData =  Utilities.decryptJsonData(jsonEncryptString: response.result.value!)
//                print(decryptData)
//                let jsonData = Utilities.convertToJSON(text: decryptData)
//                
//                completion(true, jsonData as! Dictionary<String, AnyObject>)
                
            case .failure(let error):
                
                Utilities.isRefreshBtnClick = false
                showErrorMessage(error: error as NSError)
                return
                
                
            }
        }
        
        
    }
    
    
    static func SalesforceCaseData(restApiUrl:String, params:[String:String]? = nil, methodType:String? = "POST" ,completion: @escaping AccessTokenCompletion) {

        
        let url = URL(string: SalesforceConfig.hostUrl + restApiUrl)!
        var urlRequest = URLRequest(url: url)
        
        if(methodType == "POST"){
            urlRequest.httpMethod = "POST"
            
            
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params!, options: [])
            } catch {
                
            }
        }
        else{
            urlRequest.httpMethod = "GET"
        }
        
        urlRequest.setValue("OAuth \(salesforceAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        
        Alamofire.request(urlRequest).validate().responseJSON{ response in
            switch response.result {
                
            case .success:
             if response.result.value != nil {
              
                 completion(true, response.result.value as! Dictionary<String, AnyObject>)
              }
                
            case .failure(let error):
                
                Utilities.isRefreshBtnClick = false
                showErrorMessage(error: error as NSError)
                return
                
                
            }
        }
        
        
    }
    
    
    //    func isBaseMapDownloaded(chart: Chart) -> Bool {
    //        if let path = chart.urlInDocumentsDirectory?.path {
    //            let fileManager = NSFileManager.defaultManager()
    //            return fileManager.fileExistsAtPath(path)
    //        }
    //        return false
    //    }
    //
    
    static func downloadBaseMap(baseMapUrl: String,completionHandler: @escaping (Double?, NSError?) -> Void) {
        
        //        guard isBaseMapDownloaded(chart) == false else {
        //            completionHandler(1.0, nil) // already have it
        //            return
        //        }
        
        //        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("NewYorkCity.mmpk")
            
            return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        
        Alamofire.download(
            baseMapUrl,
            method: .get,
            to: destination).downloadProgress(closure: { (progress) in
                
                let progressComplete = progress.fractionCompleted
                print(progressComplete)
                
                completionHandler(progressComplete, nil)
                
                //                DispatchQueue.main.async {
                //                    let progressComplete = progress.fractionCompleted
                //                    print(progressComplete)
                //
                //                    completionHandler(progressComplete, nil)
                //                }
            }).validate().response(completionHandler: { (DefaultDownloadResponse) in
                
                //DefaultDownloadResponse.destinationURL!.lastPathComponent
                //                if let destinationUrl = DefaultDownloadResponse.destinationURL ? {
                //                    completionHandler(destinationUrl)
                //                }
                
                
                if let error = DefaultDownloadResponse.error{
                    completionHandler(nil, error as NSError?)
                }
                
                
                
            })
        
        
        
        //        Alamofire.download(.GET, baseMapUrl, destination: destination)
        //            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
        //                print(totalBytesRead)
        //
        //                DispatchQueue.main.async {
        //                    let progress = Double(totalBytesRead) / Double(totalBytesExpectedToRead)
        //                    completionHandler(progress, nil)
        //                }
        //            }
        //            .responseString { response in
        //                print(response.result.error)
        //                completionHandler(nil, response.result.error)
        //        }
    }
    
    static func showErrorMessage(error:NSError){
        SVProgressHUD.dismiss()
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    static func showLoginErrorMessage(error:NSError){
        SVProgressHUD.dismiss()
        print(SalesforceConfig.userName)
        print(SalesforceConfig.password)
        SVProgressHUD.showError(withStatus: "Make sure your username and password is correct")
    }
    
    
}
