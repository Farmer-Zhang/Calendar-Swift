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
    var notificationCenter: NotificationCenter?
    var printVC : UIViewController?
    
    let noticeString = ["公历：","农历：","星期：","干支："," 生肖：","冲煞：","五行：", "彭祖百忌：","吉神宜趋：", "凶神宜忌：","宜：","忌："]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        _bannerView = GDTMobBannerView.init(frame: CGRect.init(x: 20, y: SCREEN_HEIGHT - (UIDevice.current.model == "iPad" ? 95 : 55), width: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.width, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height),appkey:TAPPKEY,placementId:"6080017288353724")
        
        _interstitialObj = GDTMobInterstitial.init(appkey: TAPPKEY, placementId: "7060516208552705")
        _interstitialObj?.isGpsOn = false; //【可选】设置GPS开关
        //预加载广告
        _interstitialObj?.loadAd()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override func viewWillAppear( _ animated: Bool) {
        notificationCenter = NotificationCenter.default
        let operationQueue = OperationQueue.main
        
        applicationDidEnterForegroundObserver = notificationCenter?.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: operationQueue, using: { (notification: Notification?) in
            print("程序进入到qian台了")
            if self.isADClosed == true {
                //预加载广告
                self._interstitialObj?.loadAd()
                self._interstitialObj?.present(fromRootViewController: self.printVC)
            }

        })
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //如果不需要的话，记得把相应的通知注册给取消，避免内存浪费或奔溃
        notificationCenter?.removeObserver(applicationDidEnterForegroundObserver!)
        applicationDidEnterForegroundObserver = nil
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView.register(UINib.init(nibName: "YYDetailTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        loadDatasAndRefreshView()
        
        _bannerView?.currentViewController = self; //设置当前的ViewController
        _bannerView?.interval = 30; //【可选】设置刷新频率;默认30秒
        _bannerView?.isGpsOn = false; //【可选】开启GPS定位;默认关闭
        _bannerView?.showCloseBtn = true; //【可选】展示关闭按钮;默认显示
        _bannerView?.isAnimationOn = true; //【可选】开启banner轮播和展现时的动画效果;默认开启
        self.view.addSubview(_bannerView!)    //添加到当前的view中
        _bannerView?.loadAdAndShow(); //加载广告并展示
        
        printVC = UIApplication.shared.keyWindow?.rootViewController

        Timer.scheduledTimer( timeInterval: 3, target: self, selector: #selector(pushInterstitialObjAD), userInfo: nil, repeats: false)
    }
    
    func loadDatasAndRefreshView() -> Void {
        let dic = ["key" : "0875fc61c8c696ee3b213ef819e24a3a", "date": self.title!]
        request.requestWithData(url: "http://v.juhe.cn/laohuangli/d", parameters: dic as AnyObject?)
        request.initBackDataFunc { (response, error) in
            
            print(response?["reason"] as! String)
            
            if  let dic = response?["result"] as? NSDictionary {
                self.detailTexts.add(dic["yangli"]!)
                let yinli = dic["yinli"] as! String
                let nongli = yinli.components(separatedBy:"年")[1]
                let ganzhi = yinli.components(separatedBy:"(")[0]
                let shengxiao = yinli.components(separatedBy:"(")[1].components(separatedBy:")")[0]
                
                self.detailTexts.add(nongli)
                self.detailTexts.add(YYDataMaster.init().getChineseWeekDay(englishWeekDay: self.weekDay!))
                self.detailTexts.add(ganzhi)
                self.detailTexts.add(shengxiao)
                
                self.detailTexts.add(dic["chongsha"]!)
                self.detailTexts.add(dic["wuxing"]!)
                self.detailTexts.add(dic["baiji"]!)
                self.detailTexts.add(dic["jishen"]!)
                self.detailTexts.add(dic["xiongshen"]!)
                self.detailTexts.add(dic["yi"]!)
                self.detailTexts.add(dic["ji"]!)
                
                self.detailTableView.reloadData()
            }
        }
    }
    
    func pushInterstitialObjAD() -> Void {
        _interstitialObj?.delegate = self
        //预加载广告
        //        _interstitialObj?.loadAd()
        _interstitialObj?.present(fromRootViewController: printVC)
    }
    
    func interstitialAdDidDismissFullScreenModal(_ interstitial: GDTMobInterstitial!) {
        isADClosed = false
    }
    
    func interstitialDidDismissScreen(_ interstitial: GDTMobInterstitial!) {
        isADClosed = true
    }
    
    func interstitialDidPresentScreen(_ interstitial: GDTMobInterstitial!) {
        isADClosed = false
    }

    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        didcell = tableView.dequeueReusableCell(withIdentifier: identifier) as? YYDetailTableViewCell
        didcell?.noticeLabel.text = noticeString[indexPath.row]
        if  detailTexts.count > 0 {
            didcell?.detailLabel.text = detailTexts[indexPath.row] as? String
        }
        
        return didcell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if didcell != nil {
            let getString = didcell?.detailLabel.text as NSString?
            let rect = getString?.boundingRect(with: CGSize.init(width: SCREEN_WIDTH - 102, height: 1000), options:NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)], context: nil)
            
            didcell = nil
            if ((rect?.size.height)! < CGFloat.init(30)) {
                return 30
            }
            return (rect?.size.height)!
        }
        
        didcell = nil
        return 30
    }
    
    
    override var shouldAutorotate: Bool{
        return true
    }
//    override func shouldAutorotate() -> Bool {
//        return true
//    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let height = UIScreen.main.bounds.size.height
        
        if fromInterfaceOrientation == UIInterfaceOrientation.portrait || fromInterfaceOrientation == UIInterfaceOrientation.portraitUpsideDown {
            _bannerView?.frame = CGRect.init(x: 20, y: height - (UIDevice.current.model == "iPad" ? 95 : 55), width: SCREEN_WIDTH - 40, height: GDTMOB_AD_SUGGEST_SIZE_POTRAIT.height)
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
