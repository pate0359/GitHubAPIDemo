//
//  IssueDetailViewController.swift
//  GitHubAPIDemo
//
//  Created by Nignesh on 2016-07-31.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import UIKit

class IssueDetailViewController: UITableViewController {
    
    var selectedIssue : Dictionary<String, AnyObject>!
    private var txtViewFont : UIFont!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            print("\(self.selectedIssue)")
        #endif
        
        self.txtViewFont = UIFont.systemFontOfSize(14)
        
        self.title = "Issue Details"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.selectedIssue == nil {
            return 0
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            
            let body = "\(self.selectedIssue["body"]!)"
            //Get height of body text
            let textHeight = (body.heightWithConstrainedWidth( tableView.frame.width , font:self.txtViewFont)) as CGFloat
            
            if textHeight < 100{
                
                return 100
            }
            
            return textHeight
        }
        
        return 150.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        if section == 1 && self.selectedIssue != nil {
            
            return "Issue Content"
        }else{
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("IssueDetailCell", forIndexPath: indexPath) as! IssueDetailCell
            
            // Configure cell
            
            cell.lblTitle!.text = "\(self.selectedIssue["title"]!)"
            
            // formate created date
            let strCreatedDate = self.selectedIssue["created_at"] as? String
            if strCreatedDate != nil {
            
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                let date = dateFormatter.dateFromString(strCreatedDate!)
                
                let dateFormatter1 = NSDateFormatter()
                dateFormatter1.dateFormat = "MMMM d'\(self.daySuffix(date!))' YYYY"
                
                cell.lblCreatedOn.text = "\(dateFormatter1.stringFromDate(date!))"
            }
            
            if self.selectedIssue["state"] as? String == "open" {
            
                cell.lblStatus.text = "Pending"
                
            }else if self.selectedIssue["state"] as? String == "closed"{
                
                cell.lblStatus.text = "Resolved"
            }
            
            cell.lblNoComments.text = "\(self.selectedIssue["comments"]!)"
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("IssueContentCell", forIndexPath: indexPath) as! ReadMeCell
            cell.txtViewMD.scrollEnabled = false

            if self.selectedIssue == nil || self.selectedIssue["body"] is NSNull {
                
                cell.txtViewMD.markdownText = ""
            }else{
                
                cell.txtViewMD.markdownText = "\(self.selectedIssue["body"]!)"
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Helper functions
    
    private func daySuffix(date: NSDate) -> String {
        
        let calendar = NSCalendar.currentCalendar()
        let dayOfMonth = calendar.component(.Day, fromDate: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
