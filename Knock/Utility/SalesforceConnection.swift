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
    
    
   
        
 
    private static var salesforceAccessToken:String=""
    
    
    typealias AccessTokenCompletion = (_ succeeded: Bool, _ accessToken: String?) -> Void
    
    //Refresh token handle
    
    
    
    static func loginToSalesforce(companyName:String , completion: @escaping AccessTokenCompletion) {
        
        
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
                    salesforceAccessToken = accessToken
                    completion(true, accessToken)
                } else {
                    completion(false, "")
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(false, "")
                
            }
        }
        
        
    }//end of loginToSalesforce
    

    
    
    static func SalesforceData(restApiUrl:String, params:[String:String]? = nil, completion: @escaping AccessTokenCompletion) {
        
        
        let url = URL(string: SalesforceConfig.hostUrl + restApiUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            // No-op
        }
        
        urlRequest.setValue("OAuth \(salesforceAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        
        Alamofire.request(urlRequest).validate().responseString{ response in
            switch response.result {
                
            case .success:
                    completion(true, response.result.value)
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(false, "")
                
            }
        }
        
        
    }//end of loginToSalesforce

    
    
    
    
    
}
