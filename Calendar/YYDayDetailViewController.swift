//
//  YYDayDetailViewController.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/27.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit

let identifier = "deatilCell"

class YYDayDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, GDTMobInterstitialDelegate {

    @IBOutlet weak var detailTableView: UITableView!
    var didcell : YYDetailTableViewCell?
    let request = YYBaseRequest.init()
    let detailTexts = NSMutableArray()
    var weekDay: String?
    
    //广告相关
    var isADClosed = false
    var _bannerView: GDTMobBannerView?
    var _interstitialObj: GDTMobInterstitial?
    var applicationDidEnterForegroundObserver: NSObjectProtocol?
    var notificationCenter: NSNotificationCenter?
    var printVC : UIViewController?
    
    let noticeString = ["公历：","农历：","星期：","干支："," 生肖：","冲煞：","五行：", "彭祖百忌：","吉神宜趋：", "凶神宜忌：","宜：","忌："]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        _bannerView = GDTMobBannerView.init(frame: CGRect.init(x: 20, y: SCREEN_HEIGHT - (UIDevice.currentDevice().model == "iPad" ? 95 : 55), width: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.width, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height),appkey:TAPPKEY,placementId:"6080017288353724")
        
        _interstitialObj = GDTMobInterstitial.init(appkey: TAPPKEY, placementId: "7060516208552705")
        _interstitialObj?.isGpsOn = false; //【可选】设置GPS开关
        //预加载广告
        _interstitialObj?.loadAd()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override func viewWillAppear( animated: Bool) {
        notificationCenter = NSNotificationCenter.defaultCenter()
        let operationQueue = NSOperationQueue.mainQueue()
        applicationDidEnterForegroundObserver = notificationCenter?.addObserverForName(UIApplicationWillEnterForegroundNotification,object: nil, queue: operationQueue, usingBlock: { (notification: NSNotification!) in
            print("程序进入到qian台了")
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
        
        detailTableView.registerNib(UINib.init(nibName: "YYDetailTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        loadDatasAndRefreshView()
        
        _bannerView?.currentViewController = self; //设置当前的ViewController
        _bannerView?.interval = 30; //【可选】设置刷新频率;默认30秒
        _bannerView?.isGpsOn = false; //【可选】开启GPS定位;默认关闭
        _bannerView?.showCloseBtn = true; //【可选】展示关闭按钮;默认显示
        _bannerView?.isAnimationOn = true; //【可选】开启banner轮播和展现时的动画效果;默认开启
        self.view.addSubview(_bannerView!)    //添加到当前的view中
        _bannerView?.loadAdAndShow(); //加载广告并展示
        
        printVC = UIApplication.sharedApplication().keyWindow?.rootViewController

        NSTimer.scheduledTimerWithTimeInterval( 3, target: self, selector: #selector(pushInterstitialObjAD), userInfo: nil, repeats: false)
    }
    
    func loadDatasAndRefreshView() -> Void {
        let dic = ["key" : "0875fc61c8c696ee3b213ef819e24a3a", "date": self.title!]
        request.requestWithData("http://v.juhe.cn/laohuangli/d", parameters: dic)
        request.initBackDataFunc { (response, error) in
            
            if  let dic = response?["result"] as? NSDictionary {
                self.detailTexts.addObject(dic["yangli"]!)
                let yinli = dic["yinli"] as! String
                let nongli = yinli.componentsSeparatedByString("年")[1]
                let ganzhi = yinli.componentsSeparatedByString("(")[0]
                let shengxiao = yinli.componentsSeparatedByString("(")[1].componentsSeparatedByString(")")[0]
                
                self.detailTexts.addObject(nongli)
                self.detailTexts.addObject(YYDataMaster.init().getChineseWeekDay(self.weekDay!))
                self.detailTexts.addObject(ganzhi)
                self.detailTexts.addObject(shengxiao)
                
                self.detailTexts.addObject(dic["chongsha"]!)
                self.detailTexts.addObject(dic["wuxing"]!)
                self.detailTexts.addObject(dic["baiji"]!)
                self.detailTexts.addObject(dic["jishen"]!)
                self.detailTexts.addObject(dic["xiongshen"]!)
                self.detailTexts.addObject(dic["yi"]!)
                self.detailTexts.addObject(dic["ji"]!)
                
                self.detailTableView.reloadData()
            }
        }
    }
    
    func pushInterstitialObjAD() -> Void {
        _interstitialObj?.delegate = self
        //预加载广告
        //        _interstitialObj?.loadAd()
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeString.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        didcell = tableView.dequeueReusableCellWithIdentifier(identifier) as? YYDetailTableViewCell
        didcell?.noticeLabel.text = noticeString[indexPath.row]
        if  detailTexts.count > 0 {
            didcell?.detailLabel.text = detailTexts[indexPath.row] as? String
        }
        
        return didcell!
    }
    
    func tableView(tableView: UITableView, heightForRowAt indexPath: NSIndexPath) -> CGFloat {
        if didcell != nil {
            let getString = didcell?.detailLabel.text as NSString?
            let rect = getString?.boundingRectWithSize(CGSize.init(width: SCREEN_WIDTH - 102, height: 1000), options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14.0)], context: nil)
            
            didcell = nil
            if rect?.size.height < 30 {
                return 30
            }
            return (rect?.size.height)!
        }
        
        didcell = nil
        return 30
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let height = UIScreen.mainScreen().bounds.size.height
        
        if fromInterfaceOrientation == UIInterfaceOrientation.Portrait || fromInterfaceOrientation == UIInterfaceOrientation.PortraitUpsideDown {
            _bannerView?.frame = CGRect.init(x: 20, y: height - (UIDevice.currentDevice().model == "iPad" ? 95 : 55), width: SCREEN_WIDTH - 40, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height)
        } else {
            _bannerView?.frame = CGRect.init(x: 20, y: height - GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height, width: SCREEN_HEIGHT - 40, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height)
            
        }
        _bannerView?.loadAdAndShow(); //加载广告并展示
        detailTableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
