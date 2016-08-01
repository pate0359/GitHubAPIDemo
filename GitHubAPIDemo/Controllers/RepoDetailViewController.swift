//
//  RepoDetailViewController.swift
//  GitHubAPIDemo
//
//  Created by Nignesh on 2016-07-31.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import UIKit

class RepoDetailViewController: UITableViewController, GHRepositoryDelegate {
    
    private var txtFieldRepo: UITextField!
    private var txtFieldOwner: UITextField!
    
    private var repoDetail : Dictionary<String, AnyObject>!
    private var RepoReadMe : Dictionary<String, AnyObject>!
    
    private var mGHRepository : GHRepository!
    private var txtViewFont : UIFont!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mGHRepository = GHRepository()
        mGHRepository.delegate = self
        
        // Open user Prompt
        self.promptAlertToGetRepo()
        
        self.txtViewFont = UIFont.systemFontOfSize(14)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navbar button
    private func addNavbarRightButton() {
        
        //Add rightbar button
        let issueButton : UIBarButtonItem = UIBarButtonItem(title: "Issues", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.issueButtonClicked) )
        self.navigationItem.rightBarButtonItem = issueButton
    }
    
    func issueButtonClicked() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("IssueListViewController") as! IssueListViewController
        controller.repoName = self.txtFieldRepo.text
        controller.ownerName = self.txtFieldOwner.text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Custom user input Prompt
    private func promptAlertToGetRepo() {
        
        // Prompt user for custom owner and repo
        let alert = UIAlertController(title: "Enter Owner and Repo", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        //alert.setValue(NSAttributedString(string: "Enter Owner and Repo"), forKey: "attributedTitle")
        alert.addTextFieldWithConfigurationHandler(configurationOwnerTextField)
        alert.addTextFieldWithConfigurationHandler(configurationRepoTextField)
        
        alert.addAction(UIAlertAction(title: "Get Repo", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            
            self.getRepoClicked()
            
        }))
        self.parentViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func configurationOwnerTextField(textField: UITextField!)
    {
        textField.placeholder = "Owner"
        self.txtFieldOwner = textField
    }
    private func configurationRepoTextField(textField: UITextField!)
    {
        textField.placeholder = "Repository"
        self.txtFieldRepo = textField
    }
    
    private func getRepoClicked(){
        
        //Input validation
        if self.txtFieldOwner.text!.isEmpty || self.txtFieldRepo.text!.isEmpty {
            
            // Reopen user Prompt
            self.promptAlertToGetRepo()
            return
        }
        
        // Return if network is not rechable
        if AppDelegate.sharedInstance.isNetworkRechable() == false{
            
            let alertController = UIAlertController(title: Constants.ALERT_TITLE, message: "No Internet Connectivity", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
                // Reopen user prompt
                self.promptAlertToGetRepo()
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true,completion:nil)
            return
            
        }
        
        //Request to add new employee
        mGHRepository.getRepository(self.txtFieldOwner.text!, repo: self.txtFieldRepo.text!)
    }
    
    // MARK: - GHRepositoryDelegate methods
    func succesRepository(requestType:GHRepositoryRequestType,result:Dictionary<String,AnyObject>){
        
        if requestType == .RepoDetail {
            
            self.repoDetail = result
            
            //set page title
            self.title = "\(self.repoDetail["name"]!)"
            
            //Add rightbar button
            self.addNavbarRightButton()
            
            //reload tableView
            self.tableView.reloadData()
            
            //Get ReadMe file
            mGHRepository.getReadMe(self.txtFieldOwner.text!, repo: self.txtFieldRepo.text!)
            
        }else if requestType == .RepoReadMe{
            
            self.RepoReadMe = result
            
            //reload 2nd section only
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.None )
        }
    }
    
    func failRepository(requestType:GHRepositoryRequestType,error:NSError?){
        
        // Display error message
        var msg = ""
        if requestType == .RepoDetail {
            
            msg = "Not Found"
        }else if requestType == .RepoReadMe{
            
            msg = "Error while getting ReadME file"
        }
        
        let alertController = UIAlertController(title: Constants.ALERT_TITLE, message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
            if requestType == .RepoDetail {
            
                // Reopen user prompt
                self.promptAlertToGetRepo()
            }
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if self.repoDetail == nil {
            return 0
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            
            // Safe check
            if self.RepoReadMe == nil ||  self.RepoReadMe["readme"] == nil{
                return 100
            }
            
            //Get height of read me text
            let readMe = "\(self.RepoReadMe["readme"]!)"
            let textHeight = (readMe.heightWithConstrainedWidth( tableView.frame.width , font:self.txtViewFont)) as CGFloat
            
            if textHeight < 100{
                return 100
            }
            
            return textHeight
        }
        
        return 60.0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        if section == 1 && self.repoDetail != nil {
        
            return "Readme File"
        }else{
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("RepoTitle", forIndexPath: indexPath) 
            
            // get Full name
            if self.repoDetail["full_name"] is NSNull{
                
                cell.textLabel?.text = "Anonymous Repo"
            }else{
                
                cell.textLabel?.text = "\(self.repoDetail["full_name"]!)"
            }
            
            // get star
            cell.detailTextLabel?.text = "Star : \(self.repoDetail["stargazers_count"]!)"
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RepoReadMe", forIndexPath: indexPath) as! ReadMeCell
            
            cell.txtViewMD.editable = false
            
            if self.RepoReadMe == nil || self.RepoReadMe["readme"] is NSNull {

                cell.txtViewMD.markdownText = ""
            }else{
                
                cell.txtViewMD.markdownText = "\(self.RepoReadMe["readme"]!)"
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}