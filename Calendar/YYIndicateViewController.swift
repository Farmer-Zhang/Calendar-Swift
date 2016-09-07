//
//  YYIndicateViewController.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/23.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit


//类似oc中的宏定义
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
//定义农历显示到的年份 最小1971 最大2100
private let GOYEAR = 2100

let GDTMOB_AD_SUGGEST_SIZE_POTRAIT = CGSize.init(width: SCREEN_WIDTH - 40, height: UIDevice.currentDevice().model == "iPad" ? 90 : 50)

class YYIndicateViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, GDTMobInterstitialDelegate {
    
    @IBOutlet weak var dataCollectionView: UICollectionView!
    @IBOutlet weak var searchHeight: NSLayoutConstraint!

    var didCell: NSIndexPath?
    let dataMaster: YYDataMaster = YYDataMaster.init()
    let currentYear: Int = 1970
    let vocationDays = NSMutableArray()
    var vocations = NSMutableArray()
    var workDays = NSArray()
    var dateString = ""
    var isSearch = true
    
    //广告相关
    var isADClosed = false
    var _bannerView: GDTMobBannerView?
    var _interstitialObj: GDTMobInterstitial?
    var applicationDidEnterForegroundObserver: NSObjectProtocol?
    var notificationCenter: NSNotificationCenter?
    var printVC : UIViewController?

    required init?(coder aDecoder: NSCoder) {
        _bannerView = GDTMobBannerView.init(frame: CGRect.init(x: 20, y: SCREEN_HEIGHT - (UIDevice.currentDevice().model == "iPad" ? 95 : 55), width: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.width, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height),appkey:TAPPKEY,placementId:"6080017288353724")
        
        _interstitialObj = GDTMobInterstitial.init(appkey: TAPPKEY, placementId: "7060516208552705")
        _interstitialObj?.isGpsOn = false; //【可选】设置GPS开关
        //预加载广告
        _interstitialObj?.loadAd()
        
        super.init(coder: aDecoder)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        notificationCenter = NSNotificationCenter.defaultCenter()
        let operationQueue = NSOperationQueue.mainQueue()
        applicationDidEnterForegroundObserver = notificationCenter?.addObserverForName(UIApplicationWillEnterForegroundNotification,object: nil, queue: operationQueue, usingBlock: { (notification: NSNotification!) in
            if self.isADClosed == true {
                //预加载广告
                self._interstitialObj?.loadAd()
                self._interstitialObj?.presentFromRootViewController(self.printVC)
            }
        })
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        //如果不需要的话，记得把相应的通知注册给取消，避免内存浪费或奔溃
        notificationCenter?.removeObserver(applicationDidEnterForegroundObserver!)
        applicationDidEnterForegroundObserver = nil
        super.viewWillDisappear(animated)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "📅日历"
        searchHeight.constant = 0
        printVC = UIApplication.sharedApplication().keyWindow?.rootViewController

        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait {
             setCollectionViewFlowLayout(SCREEN_WIDTH)
        } else {
             setCollectionViewFlowLayout(SCREEN_HEIGHT)
        }
        
        dataCollectionView.registerNib(UINib.init(nibName: "YYDayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        dataCollectionView.registerNib(UINib.init(nibName: "YYSectionHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        let date = dataMaster.getCurrentDate()
        request( String.init(format: "%d", date.year), foryear:true)
        
        _bannerView?.currentViewController = self; //设置当前的ViewController
        _bannerView?.interval = 30; //【可选】设置刷新频率;默认30秒
        _bannerView?.isGpsOn = false; //【可选】开启GPS定位;默认关闭
        _bannerView?.showCloseBtn = true; //【可选】展示关闭按钮;默认显示
        _bannerView?.isAnimationOn = true; //【可选】开启banner轮播和展现时的动画效果;默认开启
        self.view.addSubview(_bannerView!)    //添加到当前的view中
        _bannerView?.loadAdAndShow(); //加载广告并展示
        
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(YYIndicateViewController.pushInterstitialObjAD), userInfo: nil, repeats: false)
    }
    
    
    func pushInterstitialObjAD() -> Void {
        _interstitialObj?.delegate = self
        //预加载广告
        _interstitialObj?.presentFromRootViewController(printVC)
    }
    
    
    func interstitialAdDidDismissFullScreenModal(interstitial: GDTMobInterstitial!) {
        isADClosed = false
    }
    
    
    func interstitialDidDismissScreen(interstitial: GDTMobInterstitial!) {
         isADClosed = true
    }
    
    
    func interstitialDidPresentScreen(interstitial: GDTMobInterstitial!) {
        isADClosed = false
    }
    
    
    func setCollectionViewFlowLayout(screenWidth: CGFloat) -> Void {
        var cellw: CGFloat = 0.0
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait {
            cellw = screenWidth / 7.0;
        } else {
           cellw = screenWidth / 7.2;
        }
        
        let flowLayout = UICollectionViewFlowLayout.init();
        flowLayout.itemSize = CGSize.init(width: cellw, height: 50)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.headerReferenceSize = CGSize.init(width: screenWidth, height: 55)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 5, right: 0)
        
        dataCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        
        let date = dataMaster.getCurrentDate()
        scrollToDate(date.year, month: date.month, day: date.day)
    }
    
    
    func  request(httpArg: String,foryear : Bool) {
        let url = "http://apis.baidu.com/xiaogg/holiday/holiday"
        let gethttpArg = "d=" + httpArg
        let req = NSMutableURLRequest.init(URL: NSURL(string: url + "?" + gethttpArg)! as NSURL)
        req.timeoutInterval = 6
        req.HTTPMethod = "GET"
        req.addValue("b2e3a5f4f78a94f62d2c173ec4589644", forHTTPHeaderField: "apikey")
        NSURLConnection.sendAsynchronousRequest(req as NSURLRequest, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) -> Void in
            if error != nil{
                self.getLocalWorkHolidays()
            }
            if let d = data {
                if foryear {
                    let json = try? NSJSONSerialization.JSONObjectWithData( d, options: NSJSONReadingOptions.init(rawValue: 0)) as! NSDictionary
                    if let arr = json?[httpArg] {
                        self.vocations.addObjectsFromArray(arr as! [AnyObject])
                    }
                   self.getLocalWorkHolidays()
                } else {
                    print(String.init(data: d, encoding: NSUTF8StringEncoding))
                }
            }
        }
    }
    
    
    func getLocalWorkHolidays() -> Void {
        let path = NSBundle.mainBundle().pathForResource("workHoliday", ofType: "plist")
        let data = NSDictionary.init(contentsOfURL: NSURL.init(fileURLWithPath: path!))
    
        let date = dataMaster.getCurrentDate()
        let dic = data?[String.init(format: "%d", date.0)]
        let voc = dic?["vocation"] as! NSArray
        
        for item in voc {
            if self.vocations.containsObject(item) == false {
                self.vocations.addObject(item)
            }
        }
        workDays = dic?["workday"] as! NSArray
    }
    
    
    override func viewDidAppear(animated: Bool) {
        let date = dataMaster.getCurrentDate()
        scrollToDate(date.year, month: date.month, day: date.day)
        super.viewDidAppear(animated)
        
    }
    
    
    @IBAction func searchTheDate(sender: AnyObject) {
        if (isSearch) {
            isSearch = false
            searchHeight.constant = 44
        } else {
            isSearch = true
            searchHeight.constant = 0
        }
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
        if ((searchBar.text?.isEmpty) == nil) {
             YYUtils.showHud("请输入日期", view: self.view)
            return
        }
        if ((searchBar.text?.rangeOfString("-")) == nil) {
            YYUtils.showHud("请按照提示输入", view: self.view)
            return
        }
        
         let date = dataMaster.getCurrentDate()
        var scrollYear = date.year
        let textArray = searchBar.text?.componentsSeparatedByString("-")
        if let year = Int((textArray?[0])!) {
            if year < 1970 || year > 2099 {
                //超出范围
               YYUtils.showHud("请输入1970至2099之间的年份", view: self.view)
                return
            } else {
                scrollYear = year
            }
        }

        var scrollMonth = date.month
        if (textArray?.count)! >= 2 && (textArray?[1].isEmpty == false) {
            if let month = Int((textArray?[1])!) {
                if month <= 0 || month > 12 {
                    //超出范围
                    YYUtils.showHud("请输入1至12之间的月份", view: self.view)
                    return
                } else {
                    scrollMonth = month
                }
            }
        } else {
            //没输入月份
            YYUtils.showHud("请输入1至12之间的月份", view: self.view)
            return
        }
        
        var scrollDay = 1
        if textArray?.count >= 3 {
            if let day = Int((textArray?[2])!) {
                let days = dataMaster.getDaysInMonth(scrollMonth, month: scrollMonth)
                if day <= 0 && day > days {
                    //报错
                    YYUtils.showHud("请输入合理的天数", view: self.view)
                    return
                } else {
                    scrollDay = day
                }
            }
        }
        scrollToDate(scrollYear, month: scrollMonth, day: scrollDay)
    }
    
    
    @IBAction func todayButtonClicked(sender: AnyObject) {
        let date = dataMaster.getCurrentDate()
        scrollToDate(date.year, month: date.month, day: date.day)
    }
    
    
    func scrollToDate(year: Int, month: Int, day: Int) -> Void {
        
        let indexsection = (year - 1970) * 12 + month - 1
        let indexrow =  day + dataMaster.getIndexOfCurrentDay(year, month: month) - 1
        
        let indexpath = NSIndexPath.init(forRow: indexrow, inSection: indexsection) as NSIndexPath
        didCell = indexpath
        dataCollectionView.scrollToItemAtIndexPath(indexpath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
        dataCollectionView.reloadData()
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (2100 - 1970) * 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! YYDayCollectionViewCell
            
            let year = currentYear + indexPath.section / 12
            let month = indexPath.section % 12 + 1
            
            if  indexPath.row >=  dataMaster.getIndexOfCurrentDay(year, month: month) {
                var lularString = " "
                if year <= GOYEAR {
                    lularString = dataMaster.covertTheGregorianToLunar(year, month: month, day: indexPath.row - dataMaster.getIndexOfCurrentDay(year, month: month) + 1)
                }
                
                if indexPath == didCell {
                    cell.updateCell(indexPath.row - dataMaster.getIndexOfCurrentDay(year, month: month), isSelected: true, lularString: lularString)
                } else {
                    cell.updateCell(indexPath.row - dataMaster.getIndexOfCurrentDay(year, month: month), isSelected: false,lularString: lularString)
                }
                
                getVocationsAndWorkDays(cell, year: year, month: month, day: ( indexPath.row - dataMaster.getIndexOfCurrentDay(year, month: month) + 1))
            } else {
                cell.updateCell(-1, isSelected: false, lularString: " ")
            }
            
            let date = dataMaster.getCurrentDate()
            let indexsection = (date.0  - 1970) * 12 + date.month - 1
            let indexrow =  date.2
            if (indexPath.section ==  indexsection) && indexrow == (indexPath.row - dataMaster.getIndexOfCurrentDay(year, month: month) + 1) {
                cell.shawdowImageView.layer.cornerRadius = 18
                cell.shawdowImageView.layer.masksToBounds = true
                cell.shawdowImageView.backgroundColor = UIColor.redColor()
                cell.dayLabel.textColor = UIColor.whiteColor()
                cell.lularLabel.textColor = UIColor.whiteColor()
            }
            return cell

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let year = currentYear + section / 12
        let month = section % 12 + 1
        return dataMaster.getDaysInMonth(year, month: month) + dataMaster.getIndexOfCurrentDay(year, month: month)
    }
    
    
    func getVocationsAndWorkDays(cell: YYDayCollectionViewCell, year: Int, month: Int, day: Int) -> Void {
        //判断假期
        let currentdate = dataMaster.getCurrentDate()
        let monthAndDay = String.init(format: "%02d%02d", month,day)
        cell.vocationLabel.hidden = true
        cell.vocationLabel.backgroundColor = UIColor.init(red: 15/255.0, green: 198/255.0, blue: 249/255.0, alpha: 1.0)
        cell.vocationLabel.text = "休"
        
        if year ==  currentdate.year{
            if vocations.containsObject(monthAndDay) {
                cell.vocationLabel.hidden = false
            }
            let dayDetail = dataMaster.getOnday(year, month: month, day: day)
            //判断周六日的状态
            if dayDetail.3 == "周六" || dayDetail.3 == "Sat" || dayDetail.3 == "周日" || dayDetail.3 == "Sun" {
                let tempt = String.init(format: "%02d%02d", month, day)
                if self.vocations.containsObject(tempt) {
                    cell.vocationLabel.hidden = false
                }
                
                if workDays.containsObject(tempt) {
                    cell.vocationLabel.hidden = false
                    cell.vocationLabel.backgroundColor = UIColor.purpleColor()
                    cell.vocationLabel.text = "班"
                }
            }
        } else {
            cell.vocationLabel.hidden = true
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var header : YYSectionHeaderReusableView?
        if kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as? YYSectionHeaderReusableView
        }
        header?.updateTheHeader(currentYear + indexPath.section / 12, month: indexPath.section % 12 + 1)
        return header!
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didCell = indexPath
        collectionView.reloadData()
        
        let year = currentYear + indexPath.section / 12
        let month = indexPath.section % 12 + 1
        let day = indexPath.row - dataMaster.getIndexOfCurrentDay(year, month: month) + 1
        
        let detail = YYDayDetailViewController.init(nibName: "YYDayDetailViewController", bundle: nil)
        detail.title = String.init(format: "%d-%02d-%02d",year, month, day)
        detail.weekDay = dataMaster.getOnday(year, month: month, day: day).3
        
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        if fromInterfaceOrientation == UIInterfaceOrientation.Portrait || fromInterfaceOrientation == UIInterfaceOrientation.PortraitUpsideDown {
            setCollectionViewFlowLayout(width)
            _bannerView?.frame = CGRect.init(x: 20, y: height - (UIDevice.currentDevice().model == "iPad" ? 95 : 55), width: SCREEN_WIDTH - 40, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height)
        } else {
            setCollectionViewFlowLayout(width)
            _bannerView?.frame = CGRect.init(x: 20, y: height - GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height, width: SCREEN_HEIGHT - 40, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height)
        }
        _bannerView?.loadAdAndShow(); //加载广告并展示
    }
    
}
