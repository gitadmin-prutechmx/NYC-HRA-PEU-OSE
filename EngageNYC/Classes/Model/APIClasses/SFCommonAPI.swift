//
//  SFCommonAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

class SFCommonAPI: NSObject
{
    func sendRequest(request:SFRestRequest,callback: @escaping ((Any)->()), failure: ((String)->())?=nil)
    {
        SFRestAPI.sharedInstance().send(request, fail: { (error) in
            DispatchQueue.main.async
                {
                    if let failure = failure
                    {
                        if let errorDescription = error?.localizedDescription
                        {
                            failure(errorDescription)
                        }
                        else{
                            failure("Unknow Error")
                        }
                    }
            }
        }) { (response) in
            DispatchQueue.main.async
                {
                    callback(response!)
            }
        }
    }
}

