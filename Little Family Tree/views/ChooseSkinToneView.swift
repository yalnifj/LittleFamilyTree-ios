//
//  ChooseSkinToneView.swift
//  Little Family Tree
//
//  Created by Bryan  Farnworth on 1/18/17.
//  Copyright © 2017 Melissa. All rights reserved.
//

import UIKit

class ChooseSkinToneView: UIView {
    var view:UIView!
    
    @IBOutlet weak var lightBtn: UIButton!
    @IBOutlet weak var midBtn: UIButton!
    @IBOutlet weak var darkBtn: UIButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    var selectedPerson:LittlePerson?
    var listener:ChooseSkinToneListener?
    
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
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        addSubview(view)
        
        if selectedPerson != nil {
            let lImage = TextureHelper.getDefaultPortraitImageBySkin(selectedPerson!, skinTone: "light")
            lightBtn.imageView?.image = lImage
            
            let mImage = TextureHelper.getDefaultPortraitImageBySkin(selectedPerson!, skinTone: "mid")
             midBtn.imageView?.image = mImage
            
            let dImage = TextureHelper.getDefaultPortraitImageBySkin(selectedPerson!, skinTone: "dark")
            darkBtn.imageView?.image = dImage
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "ChooseSkinToneView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
        listener?.cancelled()
    }
    
    @IBAction func lightButtonClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        listener?.onSelected(skinTone: "light")
    }
    
    @IBAction func midButtonClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        listener?.onSelected(skinTone: "mid")
    }
    
    @IBAction func darkButtonClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        listener?.onSelected(skinTone: "dark")
    }
}

protocol ChooseSkinToneListener {
    func onSelected(skinTone:String)
    func cancelled()
}
