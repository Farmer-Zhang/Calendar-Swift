//
//  YYDetailTableViewCell.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/28.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

class YYDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
