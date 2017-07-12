//
//  YYDataMaster.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/22.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

class YYDataMaster: NSObject {

    //用于计算当前月第一天的位置
    func getIndexOfCurrentDay(year: Int, month: Int) -> Int {
        //算出本月1号是周几
        let daa = getOnday(year: year, month:month , day: 1)
        
        switch daa.3 {
        case "Sun","周日":
            return 0
        case "Mon","周一":
            return 1
        case "Tue","周二":
            return 2
        case "Wed","周三":
            return 3
        case "Thu","周四":
            return 4
        case "Fri","周五":
            return 5
        case "Sat","周六":
            return 6
        default:
            return 0
        }
    }
    
    //获取当天的 年 月 日 周几
    func getOnday(year: Int, month: Int, day: Int) -> (Int, String, String ,String) {
        
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        
        
        let componet = NSDateComponents.init()
        componet.year = year - 1970;
        componet.month = month - 1;
        componet.day = day - 1;
        
        
        let newdate = calendar?.date(byAdding: componet as DateComponents, to: NSDate.init(timeIntervalSince1970:0) as Date, options: NSCalendar.Options.init(rawValue: 0))
        let dateformater = DateFormatter.init()
        dateformater.dateFormat = "YYYY MM dd EEE"
        let dayString = dateformater.string(from: newdate!)
        let arr = dayString.components(separatedBy: " ")
//        let arr = dayString.componentsSeparatedByString(" ")
        
        return (Int(arr[0])!, arr[1],arr[2],arr[3])
    }
    
    func getChineseWeekDay(englishWeekDay: String) -> String {
        switch englishWeekDay {
        case "Sun","周日":
            return "星期天"
        case "Mon","周一":
            return "星期一"
        case "Tue","周二":
            return "星期二"
        case "Wed","周三":
            return "星期三"
        case "Thu","周四":
            return "星期四"
        case "Fri","周五":
            return "星期五"
        case "Sat","周六":
            return "星期六"
        default:
            return ""
        }
    }
    
    
    //计算当前月有多少天
    func getDaysInMonth(year: Int, month: Int) -> Int {
        if((month == 0)||(month == 1)||(month == 3)||(month == 5)||(month == 7)||(month == 8)||(month == 10)||(month == 12)) {
            return 31
        }
        if((month == 4)||(month == 6)||(month == 9)||(month == 11)) {
            return 30
        }
        if((year%4 == 1)||(year%4 == 2)||(year%4 == 3)) {
            return 28
        }
        if(year%400 == 0) {
            return 29
        }
        if(year%100 == 0) {
            return 28
        }
        return 29
    }
    
    
    func getCurrentMonthAndYear(month: Int, year: Int) -> (String) {
        var temp = "一月"
        switch  month{
        case 1:
            temp = "一月"
            break;
        case 2:
            temp = "二月"
            break;
        case 3:
            temp = "三月"
            break;
        case 4:
            temp = "四月"
            break;
        case 5:
            temp = "五月"
            break;
        case 6:
            temp = "六月"
            break;
        case 7:
            temp = "七月"
            break;
        case 8:
            temp = "八月"
            break;
        case 9:
            temp = "九月"
            break;
        case 10:
            temp = "十月"
            break;
        case 11:
            temp = "十一月"
            break;
        case 12:
            temp = "十二月"
            break;
        default:
            break;
        }
        temp = temp + "  " + String.init(format: "%d", year)
        
        return temp
    }
    
    //公历转农历
    func covertTheGregorianToLunar(year: Int, month: Int, day: Int) ->  String {
        
        let months = NSArray.init(array: ["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"])
        let chineseDays = NSArray.init(array: ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七","十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"])
        
        let dateString = NSString.init(format: "%d-%d-%d", year,month,day)
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let date = dateFormater.date(from: dateString as String)
        
        let localeCalendar = NSCalendar.init(identifier: NSCalendar.Identifier.chinese)
        
        let localeComp = localeCalendar?.components(NSCalendar.Unit.day, from: date!)
        
        var d_str = chineseDays.object(at: (localeComp?.day)! - 1)
        
        if d_str as! String == "初一" {
            let montComp = localeCalendar?.components(NSCalendar.Unit.month, from: date!)
            d_str = months.object(at: (montComp?.month)! - 1)
        }
        return d_str as! String
    }

    func getCurrentDate() -> (year: Int, month: Int, day: Int) {
        let date = NSDate.init()
        let formate = DateFormatter.init()
        formate.dateFormat = "yyyy-MM-dd"
        let string = formate.string(from: date as Date)
        let stringArr = string.components(separatedBy: "-")
//        let stringArr = string.componentsSeparatedByString("-")
        
        return (Int(stringArr[0])!,Int(stringArr[1])!,Int(stringArr[2])!)
    }


}
