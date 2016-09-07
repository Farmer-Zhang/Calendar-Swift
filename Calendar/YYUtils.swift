//
//  YYUtils.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/28.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

class YYUtils: NSObject {
   class func showHud(text: String,view: UIView)  {
        MBProgressHUD.hideHUDForView(view, animated: false)
        if text.isEmpty == true {
            
        }
        
        let hud = MBProgressHUD.init(view: view)
        hud?.mode = MBProgressHUDMode.Text
        hud?.detailsLabelText = text
        hud?.margin = 10
        hud?.removeFromSuperViewOnHide = true
        hud?.userInteractionEnabled = false
        hud?.center = view.center
        view.addSubview(hud!)
        hud?.show(true)
        hud?.hide(true, afterDelay: 2.5)
    }
    
    class func hideHud(view: UIView) {
       MBProgressHUD.hideHUDForView(view, animated: false)
    }
}
