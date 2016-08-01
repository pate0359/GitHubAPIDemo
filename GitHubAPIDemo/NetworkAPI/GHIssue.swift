//
//  GHIssue.swift
//  GitHubAPIDemo
//
//  Created by Nignesh on 2016-07-31.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import Foundation
import Alamofire

//Enum to differentiate requests
public enum GHIssueRequestType {
    case OpenIssues
    case ClosedIssues
}

//GHIssue protocol for success/fail request
protocol GHIssueDelegate{
    
    func successIssue(requestType:GHIssueRequestType,result:NSArray)
    func failIssue(requestType:GHIssueRequestType,error:NSError?)
}

class GHIssue {
    
    var delegate:GHIssueDelegate?
    var requestType : GHIssueRequestType = .OpenIssues
    
    func getOpenIssues(owner:String!,repo:String!) {
        
        self.requestType  = .OpenIssues
        
        // Set headers
        let headers = [
            "Content-Type": "application/json"
        ]
        
        let url:String = "\(Constants.API_URL)repos/\(owner)/\(repo)/issues?state=open"
        
        //request
        self.repositoryIssuesRequest(.GET, url: url, headers: headers)
    }
    
    func getClosedIssues(owner:String!,repo:String!) {
        
        self.requestType = .ClosedIssues
        
        // Set headers
        let headers = [
            "Content-Type": "application/json"
        ]
        let url:String = "\(Constants.API_URL)repos/\(owner)/\(repo)/issues?state=closed"
        
        //request
        self.repositoryIssuesRequest(.GET, url: url, headers: headers)
    }
    
    // MARK: - Almofire request for Organizations
    private func repositoryIssuesRequest(method : Alamofire.Method,url: URLStringConvertible, headers:[String: String]){
        
        Alamofire.request(method, url, encoding : .JSON, headers:headers)
            .responseJSON { response in
                #if DEBUG
                    print("\(response.request)")  // original URL request
                    print("\(response.response)") // URL response
                    print("\(response.result)")   // result of response serialization
                #endif
                
                //Check for failure
                guard response.result.isSuccess else{
                    
                    //Call delegate Error method
                    self.delegate?.failIssue(self.requestType,error: response.result.error)
                    return
                }
                
                if response.result.value! is NSArray{
                    
                    if let result : NSArray = response.result.value! as? NSArray{
                        
                        #if DEBUG
                            print("JSON: \(result)")
                        #endif
                        
                        //Call delegate Success method
                        self.delegate?.successIssue(self.requestType,result: result as NSArray)
                    }
                    
                }else{
                    
                    //Call delegate Error method
                    self.delegate?.failIssue(self.requestType,error: NSError(domain: "com.GHAPIDemo", code: 12345, userInfo: ["message" : "Not Found"]))
                    return
                }
        }
    }
}