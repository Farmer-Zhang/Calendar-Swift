//
//  YYBaseRequest.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/24.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

typealias callBackSuccesAndError = (_ response: AnyObject?, _ error: NSError?) -> Void

class YYBaseRequest: NSObject {

    
    
    var myfunc: callBackSuccesAndError?
    
    
    let vocationsDatas: [String] = Array()
    
    
    func initBackDataFunc(senderFunc: @escaping callBackSuccesAndError) -> Void {
        myfunc = senderFunc
    }
    
    
    func requestWithData(url: String, parameters: AnyObject?) -> Void {
        let manager = AFHTTPSessionManager.init()
        manager.post(url, parameters: parameters, progress: nil, success: { (resultTask:URLSessionDataTask, response:Any?) in
            self.myfunc!(response as AnyObject? ,nil)
        }) { (resultTask:URLSessionDataTask?, error:Error?) in
            self.myfunc!(nil ,error as NSError?)
        }
    }
}
