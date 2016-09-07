//
//  YYDayCollectionViewCell.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/23.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

class YYDayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var shawdowImageView: UIImageView!
    @IBOutlet weak var lularLabel: UILabel!
    @IBOutlet weak var vocationLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

//        self.layer.masksToBounds
        
    }
    
    func updateCell(row: Int, isSelected: Bool, lularString: String) -> Void {        
        dayLabel.text = ""
        lularLabel.text = ""
        lularLabel.textColor = UIColor.blackColor()
        dayLabel.textColor = UIColor.blackColor()
        shawdowImageView.layer.cornerRadius = 0
        shawdowImageView.backgroundColor = UIColor.clearColor()
        shawdowImageView.layer.masksToBounds = false
        vocationLabel.hidden = true
        vocationLabel.backgroundColor = UIColor.init(red: 15/255.0, green: 198/255.0, blue: 249/255.0, alpha: 1.0)
        vocationLabel.text = "休"
        if row >= 0 {
            lularLabel.text = lularString
            dayLabel?.text = String.init(format: "%d", row + 1)
            if isSelected {
                lularLabel.textColor = UIColor.whiteColor()
                dayLabel.textColor = UIColor.whiteColor()
                shawdowImageView.layer.cornerRadius = 18
                shawdowImageView.backgroundColor = UIColor.blueColor()
                shawdowImageView.layer.masksToBounds = true
            }
        }
    }
}
