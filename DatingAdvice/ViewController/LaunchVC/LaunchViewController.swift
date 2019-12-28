//
//  LaunchViewController.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController,UIScrollViewDelegate,MHPagingScrollViewDelegate {
   
    

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var pagingScrollView: MHPagingScrollView!
   // var headingArray : NSArray?
    var _numPages:UInt? = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initArrays()
//        pagingScrollView.backgroundColor = UIColor.red
        self.initPagingScrollViewProperties()
        // Do any additional setup after loading the view.
    }
  
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.setNavigationBarHidden(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
         self.presentController()
        })
    }
    func presentController() {
        
        if  stringLoad ==  "YES" {
            
        }else{
            let str2 =   kUserTouchAndPassCode.string(forKey: "Touchid")
            
            if str2 == "NO" {
                let str1 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                if str1 == "NO"{
                    
                }else if str1 ==  "YES"{
                    let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: String("TouchScreen")) as! TouchScreen
                    
                    self.view.window?.rootViewController?.present(viewController2, animated: true, completion: nil)
                }
                
            }else if str2 == "YES"{
                let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: String("TouchScreen")) as! TouchScreen
                
                self.view.window?.rootViewController?.present(viewController2, animated: true, completion: nil)
            }
        }
        
    }
    @IBAction func pageValueChanged(_ sender: Any) {
    }
    
    @IBAction func signUpBtnAction(_ sender: Any) {
        pushView(viewController: self, identifier: "SignupVC")
    }
    @IBAction func signInButtonAction(_ sender: Any) {
        pushView(viewController: self, identifier: "WelcomeReviewVC")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initArrays() {
       // headingArray = ["African & Caribbean Restaurants Delivered","Grocery Stores Delivered","Home Cooked Meals Delivered", "Catering Delivered"]
        self.pagingScrollView.delegate = self
        self.pagingScrollView.pagingDelegate = self
    }
    
    func initPagingScrollViewProperties() {
        _numPages = 4;
       // self.edgesForExtendedLayout = .none;
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = Int(_numPages ?? 0)
        self.pagingScrollView.reloadPages()
        self.pagingScrollView.bounces = false
        self.pagingScrollView.scrollViewDidScroll()
        //Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(LaunchViewController.scrollText), userInfo: nil, repeats: true)
    }
    
    
//    @objc func scrollText()
//    {
//        if  self.pagingScrollView.indexOfSelectedPage() == _numPages! - 1
//        {
//            print(self.scrollText)
//            dispatch_get_main_queue().async()
//            {
//                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
//                    self.scrollWidth = 0.0
//                    self.pagingScrollView.contentOffset = CGPointMake(self.scrollWidth!,0)
//                    
//                }, completion:{ (finished: Bool) -> Void in
//                    self.pagingScrollView.reloadPages()
//                    self.pageControl.currentPage = Int(self.pagingScrollView.indexOfSelectedPage())
//                })
//            }
//        }
//        else
//        {
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
//                    self.scrollWidth = self.scrollWidth!+SCREEN_WIDTH
//                    self.pagingScrollView.contentOffset = CGPointMake(self.scrollWidth!,0)
//                }, completion:{ (finished: Bool) -> Void in
//                    self.pagingScrollView.scrollViewDidScroll()
//                    self.pageControl.currentPage = Int(self.pagingScrollView.indexOfSelectedPage())
//                    print(self.pageControl.currentPage)
//                })
//            }
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(self.pagingScrollView.indexOfSelectedPage())
        self.pagingScrollView.scrollViewDidScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //if self.pagingScrollView.indexOfSelectedPage() == _numPages! - 1 {
            self.pagingScrollView.reloadPages()
        //}
    }
    
    func numberOfPages(in pagingScrollView: MHPagingScrollView!) -> UInt  {
        return _numPages!
    }
    
    func pagingScrollView(_ pagingScrollView: MHPagingScrollView!, pageFor index: UInt) -> UIView! {
     
        var pageView = pagingScrollView.dequeueReusablePage() as? WelcomeView
        
        if pageView == nil
        {
            pageView = Bundle.main.loadNibNamed("WelcomeView", owner: self, options: nil)![0] as? WelcomeView
        }
        
//        if headingArray!.count > index
//        {
//            pageView!.titleLabel.text = headingArray![Int(index)] as? String ?? ""
//        }
        pageView!.titleLabel.sizeToFit()
        return pageView!
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
