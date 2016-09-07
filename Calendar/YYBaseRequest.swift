//
//  YYBaseRequest.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/24.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

typealias callBackSuccesAndError = (response: AnyObject?, error: NSError?) -> Void

class YYBaseRequest: NSObject {

    
    
    var myfunc: callBackSuccesAndError?
    
    
    let vocationsDatas: [String] = Array()
    
    
    func initBackDataFunc(senderFunc: callBackSuccesAndError) -> Void {
        myfunc = senderFunc
    }
    
    func requestWithData(url: String, parameters: AnyObject?) -> Void {
        let manager = AFHTTPSessionManager.init()
        manager.POST(url, parameters: parameters, progress: nil, success: { (resultTask:NSURLSessionDataTask, response:AnyObject?) in
            self.myfunc!(response: response ,error: nil)
        }) { (resultTask:NSURLSessionDataTask?, error:NSError?) in
            self.myfunc!(response: nil ,error: error)
        }
    }
}
