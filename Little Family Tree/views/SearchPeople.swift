//
//  SearchPeople.swift
//  Little Family Tree
//
//  Created by Melissa on 2/6/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import UIKit

class SearchPeople: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var view:UIView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var remoteIdTxt: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultsTable: UITableView!
    @IBOutlet weak var showFamilyButton: UIButton!
    
    var selectedPerson:LittlePerson?
    var personDetailsView:PersonDetailsView?
    
    var openingScene:LittleFamilyScene?
    
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
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        addSubview(view)
        
        let nib = UINib(nibName: "SearchPersonTableCell", bundle: nil)
        self.resultsTable.register(nib, forCellReuseIdentifier: "SearchPersonTableCell")
        self.resultsTable.rowHeight = 60
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "SearchPeople", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        print("Back Button Clicked")
        self.view.removeFromSuperview()
        openingScene?.showSettings()
    }
    
    @IBAction func searchButtonAction(_ sender: AnyObject) {
        let dataService = DataService.getInstance()
        let given = firstNameTxt.text
        let surname = lastNameTxt.text
        let remoteid = remoteIdTxt.text
        
        self.results = dataService.dbHelper.search(given?.trim(), surname: surname?.trim(), remoteid: remoteid)
        self.resultsTable.reloadData()
        view.endEditing(true)
    }
    
    @IBAction func showFamilyAction(_ sender: AnyObject) {
        let dataService = DataService.getInstance()
        dataService.getFamilyMembers(selectedPerson!, loadSpouse: true, onCompletion: { people, err in
            DispatchQueue.main.async {
                self.results = people!
                self.resultsTable.reloadData()
            }
        })
    }
    
    
    func showResults(_ results:[LittlePerson]) {
        self.results = results
        self.resultsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SearchPersonTableCell = self.resultsTable.dequeueReusableCell(withIdentifier: "SearchPersonTableCell")! as! SearchPersonTableCell
        let person = self.results[(indexPath as NSIndexPath).row]
        cell.setValues(person)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\((indexPath as NSIndexPath).row)!")
        let person = results[(indexPath as NSIndexPath).row]
        
        self.view?.removeFromSuperview()
        
        openingScene?.showPersonDetails(person, listener: PersonDetailsListener(results: self.results, openingScene: openingScene!))
    }
    
}

class PersonDetailsListener:PersonDetailsCloseListener {
    var results:[LittlePerson]
    var openingScene:LittleFamilyScene
    init(results:[LittlePerson], openingScene:LittleFamilyScene) {
        self.results = results
        self.openingScene = openingScene
    }
    func onPersonDetailsClose() {
        self.openingScene.showManagePeople().showResults(self.results)
    }
}
