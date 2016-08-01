//
//  IssueListViewController.swift
//  GitHubAPIDemo
//
//  Created by Nignesh on 2016-07-31.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import UIKit

class IssueListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, GHIssueDelegate {
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var segmentControll: UISegmentedControl!
    
    var repoName : String?
    var ownerName : String?
    
    private var arrayOpenIssues : NSArray?
    private var arrayClosedIssues : NSArray?
    
    private var mGHIssue : GHIssue!
    
    //Search bar
    var filteredArray = NSArray()
    var shouldShowSearchResults = false
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mGHIssue = GHIssue()
        mGHIssue.delegate = self
        
        self.segmentControll.selectedSegmentIndex = 0
        self.title = "Open Issues"
        
        self.searchBar.text = ""
        self.searchBar.delegate = self
        self.tableView.tableHeaderView = self.searchBar
        
        //get open issues
        if self.repoName != nil && self.ownerName != nil {
        
            // Return if network is not rechable
            if AppDelegate.sharedInstance.isNetworkRechable() == false{
                
                let alertController = UIAlertController(title: Constants.ALERT_TITLE, message: "No Internet Connectivity", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true,completion:nil)
                return
            }
            
            mGHIssue.getOpenIssues(self.ownerName!, repo: self.repoName!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
    
        self.searchBar.text = ""
        shouldShowSearchResults = false
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segment Controll event
    
    @IBAction func segmentControllValueChanged(sender: AnyObject) {
        
        if self.segmentControll.selectedSegmentIndex == 0 {
            
            self.title = "Open Issues"
            
            if self.arrayOpenIssues == nil || self.arrayOpenIssues?.count == 0 {
                
                if self.repoName != nil && self.ownerName != nil {
                    
                    // Return if network is not rechable
                    if AppDelegate.sharedInstance.isNetworkRechable() == false{
                        
                        let alertController = UIAlertController(title: Constants.ALERT_TITLE, message: "No Internet Connectivity", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(OKAction)
                        
                        self.presentViewController(alertController, animated: true,completion:nil)
                        return
                    }
                    
                    //get open issues
                    self.mGHIssue.getOpenIssues(self.ownerName!, repo: self.repoName!)
                }
            }
            
            //reload table
            self.tableView.reloadData()
            
        }else {
            
            self.title = "Closed Issues"
            
            if self.arrayClosedIssues == nil || self.arrayClosedIssues?.count == 0 {
                
                if self.repoName != nil && self.ownerName != nil {
                    
                    // Return if network is not rechable
                    if AppDelegate.sharedInstance.isNetworkRechable() == false{
                        
                        let alertController = UIAlertController(title: Constants.ALERT_TITLE, message: "No Internet Connectivity", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(OKAction)
                        
                        self.presentViewController(alertController, animated: true,completion:nil)
                        return
                    }
                    
                    //get closed issues
                    self.mGHIssue.getClosedIssues(self.ownerName!, repo: self.repoName!)
                }
            }
            
            //reload table
            self.tableView.reloadData()
        }
    }
    
    // MARK: - GHIssue delegate
    func successIssue(requestType:GHIssueRequestType,result:NSArray){
        
        if requestType == .OpenIssues {
            
            // Sort alphabetically
            self.arrayOpenIssues = result.sort { ($0["title"] as? String) < ($1["title"] as? String) }
            
        }else if requestType == .ClosedIssues{
            
            // Sort alphabetically
            self.arrayClosedIssues = result.sort { ($0["title"] as? String) < ($1["title"] as? String) }
        }
        
        //reload table
        self.tableView.reloadData()
    }
    
    func failIssue(requestType:GHIssueRequestType,error:NSError?){
     
        // Display error message
        var msg = ""
        if error == nil {
            msg = "Not Found"
        }else{
            msg = error!.localizedDescription
        }
        
        let alertController = UIAlertController(title: Constants.ALERT_TITLE, message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: -  Serach bar delegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        shouldShowSearchResults = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        shouldShowSearchResults = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        shouldShowSearchResults = false
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        shouldShowSearchResults = false
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            
            if self.segmentControll.selectedSegmentIndex == 0 {
                
                if self.arrayOpenIssues == nil{
                
                    self.filteredArray = NSArray()
                    return
                }
                self.filteredArray = self.arrayOpenIssues!
                
            }else{
                
                if self.arrayClosedIssues == nil{
                    
                    self.filteredArray = NSArray()
                    return
                }
                self.filteredArray = self.arrayClosedIssues!
            }
            
        }else{
            
            // Filter the data array
            if self.segmentControll.selectedSegmentIndex == 0 {
                
                self.filteredArray = self.arrayOpenIssues!.filter({ (object) -> Bool in
                    let issue = object as! Dictionary<String,AnyObject>
                    let title = issue["title"] as! NSString
                    return (title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
                })
                
            }else{
                
                self.filteredArray = self.arrayClosedIssues!.filter({ (object) -> Bool in
                    let issue = object as! Dictionary<String,AnyObject>
                    let title = issue["title"] as! NSString
                    return (title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
                })
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults {
            
            return filteredArray.count
            
        }else {
            if self.segmentControll.selectedSegmentIndex == 0 {
                
                if self.arrayOpenIssues == nil {
                    return 0
                }
                return self.arrayOpenIssues!.count
                
            }else{
                
                if self.arrayClosedIssues == nil {
                    return 0
                }
                
                return self.arrayClosedIssues!.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("IssueListCell", forIndexPath: indexPath) as! IssueListCell
        
        let dict : Dictionary<String,AnyObject>
        
        if shouldShowSearchResults {
            
            dict = self.filteredArray[indexPath.row] as! Dictionary<String,AnyObject>
            
        }else {
            
            if self.segmentControll.selectedSegmentIndex == 0 {
                
                dict = self.arrayOpenIssues![indexPath.row] as! Dictionary<String,AnyObject>
            }else{
                
                dict = self.arrayClosedIssues![indexPath.row] as! Dictionary<String,AnyObject>
            }
        }
        
        
        // Configure the cell...
        cell.lblTitle!.text = "\(dict["title"]!)"
        
        //Get issue created date
        let dateStr = "\(dict["created_at"]!)"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let date = dateFormatter.dateFromString(dateStr)
        
        cell.lblIssueAge!.text = "\(self.timeAgoSinceDate(date!, numericDates: false))"
        
        //Get user details
        let userDict = dict["user"] as? Dictionary<String,AnyObject>
        if userDict != nil && userDict!["login"] != nil {
        
            cell.btnUser.setTitle("\(userDict!["login"]!)", forState: .Normal)
        }else{
            
            cell.btnUser.setTitle("Anonymous", forState: .Normal)
        }
        
        cell.btnUser.tag = indexPath.row
        cell.btnUser.addTarget(self, action: #selector(self.btnUserClicked ), forControlEvents: .TouchUpInside)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("IssueDetailViewController") as! IssueDetailViewController
        
        let dict : Dictionary<String,AnyObject>
        
        if shouldShowSearchResults {
            
            dict = self.filteredArray[indexPath.row] as! Dictionary<String,AnyObject>
            
        }else {
            if self.segmentControll.selectedSegmentIndex == 0 {
                
                dict = self.arrayOpenIssues![indexPath.row] as! Dictionary<String,AnyObject>
            }else{
                
                dict = self.arrayClosedIssues![indexPath.row] as! Dictionary<String,AnyObject>
            }
        }
        
        controller.selectedIssue = dict
        self.navigationController?.pushViewController(controller, animated: true)
        
        // end searching
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - Cell button clicked
    func btnUserClicked(sender : AnyObject)  {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("UserModelViewController") as! UserModelViewController
        
        let dict : Dictionary<String,AnyObject>
        
        if shouldShowSearchResults {
            
            dict = self.filteredArray[sender.tag] as! Dictionary<String,AnyObject>
            
        }else {
            
            if self.segmentControll.selectedSegmentIndex == 0 {
                
                dict = self.arrayOpenIssues![sender.tag] as! Dictionary<String,AnyObject>
            }else{
                
                dict = self.arrayClosedIssues![sender.tag] as! Dictionary<String,AnyObject>
            }
        }
        
        controller.userDict = dict["user"] as? Dictionary<String,AnyObject>
        self.navigationController?.pushViewController(controller, animated: true)
        
        // end searching
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - Date Helper function
    // Credit : https://gist.github.com/jacks205/4a77fb1703632eb9ae79
    
    private func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.year >= 2) {
            return "\(components.year) years ago"
        } else if (components.year >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month >= 2) {
            return "\(components.month) months ago"
        } else if (components.month >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear) weeks ago"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day >= 2) {
            return "\(components.day) days ago"
        } else if (components.day >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour) hours ago"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute) minutes ago"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second >= 3) {
            return "\(components.second) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}
