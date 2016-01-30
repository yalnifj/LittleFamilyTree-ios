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
        
        welcomeText.text = "Little Family Tree engages toddlers and pre-school children with their personal family history through photos, games, and activities designed for their level. (Most of the games are fun for the kid in all of us.)"
        welcomeText.numberOfLines = 0
        welcomeText.sizeToFit()
        photoText.text = "The more information--especially photos--that you add to your online family tree, the more fun Little Family Tree will be for your child!"
        photoText.numberOfLines = 0
        photoText.sizeToFit()
        playTogetherText.text = "Playing with your child will give you the opportunity to strengthen family associations and enhance the experience through your personal memories and stories."
        playTogetherText.numberOfLines = 0
        playTogetherText.sizeToFit()
        choosePlayerText.text = "The games and activities in Little Family Tree are centered around the person who is playing.  You may choose a different person by using the back button or tapping the profile picture on the activity screens."
        choosePlayerText.numberOfLines = 0
        choosePlayerText.sizeToFit()
        homeActivityText.text = "The home is the hub of the game.  Tap around and explore to find interactive elements.  You may need to help the youngest to get started.  Return anytime by using the home button at the top of every screen."
        homeActivityText.numberOfLines = 0
        homeActivityText.sizeToFit()
        starsText.text = "Special games and activities are highlighted by stars on the home screen.  Follow the stars to interact in fun and unique ways with your relatives."
        starsText.numberOfLines = 0
        starsText.sizeToFit()
        
        var x = CGFloat(50)
        let y = CGFloat(0)
        let w = view.frame.width - 100
        var h = view.frame.height - 100
        if h > 400 {
            h = CGFloat(400)
        }
        
        pageWidth = view.frame.width
        
        WelcomView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(WelcomView)
        scrolledViews.append(WelcomView)
        
        x = x + w + 100
        MorePhotosView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(MorePhotosView)
        scrolledViews.append(MorePhotosView)
        
        x = x + w + 100
        PlayTogetherView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(PlayTogetherView)
        scrolledViews.append(PlayTogetherView)
        
        x = x + w + 100
        ChoosePlayerView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(ChoosePlayerView)
        scrolledViews.append(ChoosePlayerView)
        
        x = x + w + 100
        HomeActivityView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(HomeActivityView)
        scrolledViews.append(HomeActivityView)
        
        x = x + w + 100
        StarsView.frame = CGRect(x: x, y: y, width: w, height: h)
        pagedScrollView.addSubview(StarsView)
        scrolledViews.append(StarsView)
        
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
        DataService.getInstance().dbHelper.saveProperty(DataService.PROPERTY_SHOW_PARENTS_GUIDE, value: "true")
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        if (currentPage < scrolledViews.count - 1) {
            currentPage++
            let rect = scrolledViews[currentPage].frame
            pagedScrollView.scrollRectToVisible(rect, animated: true)
            prevButton.hidden = false
        }
    }

    @IBAction func prevButtonClicked(sender: AnyObject) {
        if (currentPage > 0) {
            currentPage--
            let rect = scrolledViews[currentPage].frame
            pagedScrollView.scrollRectToVisible(rect, animated: true)
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
        if currentPage < scrolledViews.count {
            nextButton.hidden = false
        } else {
            nextButton.hidden = true
        }
    }
    
}

protocol ParentsGuideCloseListener {
    func onClose()
}
