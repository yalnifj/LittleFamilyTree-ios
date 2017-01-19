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
    
    var selectedPerson:LittlePerson?
    var skinTone:String?
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
            let image = TextureHelper.getDefaultPortraitImageBySkin(selectedPerson, skinTone: skinTone)
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "ParentLogin", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func onBackButtonClick(_ sender: Any) {
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
