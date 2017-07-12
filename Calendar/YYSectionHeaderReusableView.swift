//
//  YYSectionHeaderReusableView.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/23.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

class YYSectionHeaderReusableView: UICollectionReusableView {

    @IBOutlet weak var headerTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func updateTheHeader(year: Int, month: Int) -> Void {
        
       let string = YYDataMaster.init().getCurrentMonthAndYear(month: month, year: year)
        headerTitle.text = string
    }
    
}
