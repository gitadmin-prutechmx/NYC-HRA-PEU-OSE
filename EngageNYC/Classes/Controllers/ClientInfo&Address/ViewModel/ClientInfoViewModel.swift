//
//  ClientInfoViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 24/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class ClientInfoViewModel{
    
    static func getViewModel() -> ClientInfoViewModel {
        return ClientInfoViewModel()
    }
    
    func saveNewContact(objNewContactDO:NewContactDO){
        ContactAPI.shared.saveNewContact(objNewContact:objNewContactDO,isSameUnit:true)
    }
    
    func getPrimaryLangPicklist(objectType:String,fieldName:String)->[String]{
        
        var arrPrimaryLang = [String]()
        if let picklist =  PicklistAPI.shared.getPicklist(objectType: objectType, fieldName: fieldName){
            let primaryLangStr = picklist.value!
            arrPrimaryLang = String(primaryLangStr.dropLast()).components(separatedBy: ";")
        }
        
        return arrPrimaryLang
        
    }
}
