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
}
