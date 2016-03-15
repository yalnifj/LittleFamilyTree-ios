//
//  SearchPeople.swift
//  Little Family Tree
//
//  Created by Melissa on 2/6/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import UIKit

class SearchPeople: UIView,UITableViewDelegate,UITableViewDataSource,PersonDetailsCloseListener {
    
    var view:UIView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var remoteIdTxt: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultsTable: UITableView!
    
    var selectedPerson:LittlePerson?
    var personDetailsView:PersonDetailsView?
    
    var results = [LittlePerson]()
    
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
        
        let nib = UINib(nibName: "SearchPersonTableCell", bundle: nil)
        self.resultsTable.registerNib(nib, forCellReuseIdentifier: "SearchPersonTableCell")
        self.resultsTable.rowHeight = 60
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "SearchPeople", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        print("Back Button Clicked")
        self.view.removeFromSuperview()
    }
    
    @IBAction func searchButtonAction(sender: AnyObject) {
        let dataService = DataService.getInstance()
        let given = firstNameTxt.text
        let surname = lastNameTxt.text
        let remoteid = remoteIdTxt.text
        
        self.results = dataService.dbHelper.search(given, surname: surname, remoteid: remoteid)
        self.resultsTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SearchPersonTableCell = self.resultsTable.dequeueReusableCellWithIdentifier("SearchPersonTableCell")! as! SearchPersonTableCell
        let person = self.results[indexPath.row]
        cell.setValues(person)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let person = results[indexPath.row]
        personDetailsView = PersonDetailsView(frame: (self.view?.bounds)!)
        personDetailsView?.listener = self
        personDetailsView?.selectedPerson = self.selectedPerson
        personDetailsView?.showPerson(person)
        self.view?.addSubview(personDetailsView!)
    }
    
    func onPersonDetailsClose() {
        self.userInteractionEnabled = true
        personDetailsView!.view.removeFromSuperview()
    }
}