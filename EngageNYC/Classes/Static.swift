//
//  Static.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

struct Static {
    static var refreshView: RefreshViewController?
    static var timer:Timer?
    static var isRefreshBtnClick:Bool = false
    static var isBackgroundSync:Bool = false
    static var exitMessage:String = "Are you sure you want to close without saving?"
}
