//
//  RecordAudioView.swift
//  Little Family Tree
//
//  Created by Melissa on 4/27/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit

class RecordAudioView: UIView {


    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    var view:UIView!
    
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
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "RecordAudioView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func PlayButtonClicked(sender: AnyObject) {
    }

    @IBAction func RecordButtonClicked(sender: AnyObject) {
    }
    
    @IBAction func DeleteButtonClicked(sender: AnyObject) {
    }
    
    @IBAction func BackButtonClicked(sender: AnyObject) {
    }
    

}
