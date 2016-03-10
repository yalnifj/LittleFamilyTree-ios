//
//  ParentsGuide.swift
//  Little Family Tree
//
//  Created by Melissa on 1/7/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit

class ParentsGuide: UIView, UIScrollViewDelegate {

    var view:UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pagedScrollView: UIScrollView!
    
    @IBOutlet weak var WelcomView: UIView!
    @IBOutlet weak var MorePhotosView: UIView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var photoText: UILabel!
    @IBOutlet weak var PlayTogetherView: UIView!
    @IBOutlet weak var playTogetherText: UILabel!
    @IBOutlet weak var ChoosePlayerView: UIView!
    @IBOutlet weak var choosePlayerText: UILabel!
    @IBOutlet weak var HomeActivityView: UIView!
    @IBOutlet weak var homeActivityText: UILabel!
    @IBOutlet weak var StarsView: UIView!
    @IBOutlet weak var starsText: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet var settingsView: UIView!
    @IBOutlet weak var settingsText: UILabel!
    @IBOutlet var KidHeritageView: UIView!
    @IBOutlet weak var moreText: UILabel!
    @IBOutlet weak var moreText3: UILabel!
    @IBOutlet weak var kidHeritageButton: UIButton!
    
    @IBOutlet weak var welcomeImage: UIImageView!
    @IBOutlet weak var photosImage: UIImageView!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var chooseImage: UIImageView!
    
    
    var scrolledViews = [UIView]()
    
    var listener:ParentsGuideCloseListener?
    var currentPage = 0
    var pageWidth = CGFloat(500)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        addSubview(view)
        
        closeButton.enabled      = false
        closeButton.tintColor    = UIColor.clearColor()
        
        welcomeText.text = "Little Family Tree engages young children with their personal family history through games and activities designed for their level. (Most of the games are fun for the kid in all of us.)  Visit our website for more details, videos, and tutorials about the games in Little Family Tree."
        welcomeText.numberOfLines = 0
        welcomeImage.frame.size.width = view.frame.width / 2.5
        welcomeText.sizeToFit()
        photoText.text = "The more information--especially photos--that you add to your online family tree, the more fun Little Family Tree will be for your child!"
        photoText.numberOfLines = 0
        photosImage.frame.size.width = view.frame.width / 2.5
        photoText.sizeToFit()
        
        playTogetherText.text = "Playing with your child will give you the opportunity to strengthen family associations and enhance the experience through your personal memories and stories."
        playTogetherText.numberOfLines = 0
        playImage.frame.size.width = view.frame.width / 2.5
        playTogetherText.sizeToFit()
        
        choosePlayerText.text = "The games and activities in Little Family Tree are centered around the person who is playing.  You may choose a different person by using the back button or tapping the profile picture on the activity screens."
        choosePlayerText.numberOfLines = 0
        chooseImage.frame.size.width = view.frame.width / 2.5
        choosePlayerText.sizeToFit()
        
        homeActivityText.text = "The home is the hub of the game.  Tap around and explore to find interactive elements.  You may need to help the youngest to get started.  Return anytime by using the home button at the top of every screen."
        homeActivityText.numberOfLines = 0
        homeActivityText.sizeToFit()
        
        starsText.text = "Special games and activities are highlighted by stars on the home screen.  Follow the stars to interact in fun and unique ways with your relatives."
        starsText.numberOfLines = 0
        starsText.sizeToFit()
        
        settingsText.text = "Parents may alter app settings through the manage settings button found on any screen.  You must enter the password for your online tree account in order to access the settings.  This prevents children from accidentally changing the settings."
        settingsText.numberOfLines = 0
        settingsText.sizeToFit()
        
        moreText3.text = "From the settings you can manage your connection to your online family tree and change synchronization settings. You can also choose to hide people from your online tree so that they do not show up in Little Family Tree."
        moreText3.numberOfLines = 0
        moreText3.sizeToFit()
        
        kidHeritageButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        moreText.text = "Teach your children more about their heritage with their own personal heritage book. Use coupon code LTFAMTR316 for free shipping!"
        moreText.numberOfLines = 0
        moreText.sizeToFit()
        
        
        var x = CGFloat(10)
        let y = CGFloat(0)
        let w = view.frame.width - 20
        var h = pagedScrollView.frame.height - 20
        if h > 400 {
            h = CGFloat(400)
        }
        
        pageWidth = view.frame.width
        
        WelcomView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(WelcomView)
        scrolledViews.append(WelcomView)
        
        //if welcomeImage.frame.size.width > w / 2 {
        //    welcomeImage.frame.size.width = w / 2
        //}
        
        x = x + w + 20
        MorePhotosView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(MorePhotosView)
        scrolledViews.append(MorePhotosView)
        
        x = x + w + 20
        PlayTogetherView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(PlayTogetherView)
        scrolledViews.append(PlayTogetherView)
        
        x = x + w + 20
        ChoosePlayerView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(ChoosePlayerView)
        scrolledViews.append(ChoosePlayerView)
        
        x = x + w + 20
        HomeActivityView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(HomeActivityView)
        scrolledViews.append(HomeActivityView)
        
        x = x + w + 20
        StarsView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(StarsView)
        scrolledViews.append(StarsView)
        
        x = x + w + 20
        settingsView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(settingsView)
        scrolledViews.append(settingsView)
        
        x = x + w + 20
        KidHeritageView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(KidHeritageView)
        scrolledViews.append(KidHeritageView)
        
        pagedScrollView.contentSize = CGSizeMake(x + w + 10, h)
        pagedScrollView.pagingEnabled = true
        pagedScrollView.delegate = self
        
        pageControl.numberOfPages = scrolledViews.count
        pageControl.currentPage = 0
        pageControl.hidden = true
        nextButton.hidden = false
        prevButton.hidden = true
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "ParentsGuide", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func pageChanged(sender: UIPageControl) {
        print("Page changed to \(sender.currentPage)")
        
        if scrolledViews.count > sender.currentPage {
            let page = scrolledViews[sender.currentPage]
            pagedScrollView.scrollRectToVisible(page.frame, animated: true)
        }
    }
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        self.removeFromSuperview()
        if listener != nil {
            listener!.onClose()
        }
        DataService.getInstance().dbHelper.saveProperty(DataService.PROPERTY_SHOW_PARENTS_GUIDE, value: "false")
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        if (currentPage < scrolledViews.count - 1) {
            currentPage++
            let rect = scrolledViews[currentPage].frame
            let pageRect = CGRect(x: rect.origin.x+10, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
            pagedScrollView.scrollRectToVisible(pageRect, animated: true)
            prevButton.hidden = false
        }
        if currentPage == scrolledViews.count-1 {
            closeButton.enabled      = true
            closeButton.tintColor    = nil
        }
    }

    @IBAction func prevButtonClicked(sender: AnyObject) {
        if (currentPage > 0) {
            currentPage--
            let rect = scrolledViews[currentPage].frame
            let pageRect = CGRect(x: rect.origin.x-10, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
            pagedScrollView.scrollRectToVisible(pageRect, animated: true)
        }
    }
    
    func scrollViewDidScroll(scrollView:UIScrollView ) {
        // Load the pages which are now on screen
        currentPage = NSInteger(floor((self.pagedScrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)));
        if currentPage > 0  {
            prevButton.hidden = false
        } else {
            prevButton.hidden = true
        }
        if currentPage < scrolledViews.count-1 {
            nextButton.hidden = false
        } else {
            nextButton.hidden = true
        }
        if currentPage == scrolledViews.count-1 {
            closeButton.enabled      = true
            closeButton.tintColor    = nil
        }
    }
    
    @IBAction func websiteButtonClicked(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string:"http://www.littlefamilytree.com")!)
    }
    @IBAction func kidHeritageClicked(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://www.myheritagebook.com")!)
    }
}

protocol ParentsGuideCloseListener {
    func onClose()
}
