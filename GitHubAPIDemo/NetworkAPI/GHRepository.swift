//
//  GHRepository.swift
//  GitHubAPIDemo
//
//  Created by Nignesh on 2016-07-31.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import Foundation
import Alamofire

//Enum to differentiate requests
public enum GHRepositoryRequestType {
    case RepoReadMe
    case RepoDetail
}

//GHRepository protocol for success/fail request
protocol GHRepositoryDelegate{
    
    func succesRepository(requestType:GHRepositoryRequestType,result:Dictionary<String,AnyObject>)
    func failRepository(requestType:GHRepositoryRequestType,error:NSError?)
}

class GHRepository {
    
    var delegate:GHRepositoryDelegate?
    var requestType : GHRepositoryRequestType = .RepoDetail
    
    func getRepository(owner:String!,repo:String!) {
    
        self.requestType = .RepoDetail
        
        // Set headers
        let headers = [
            "Content-Type": "application/json"
        ]
        
        let url:String = "\(Constants.API_URL)repos/\(owner)/\(repo)"

        //request url
        self.repositoryRequest(.GET, url: url, headers: headers)
    }
    
    func getReadMe(owner:String!,repo:String!) {
        
        self.requestType = .RepoReadMe
        
        // Set headers
        let headers = [
            "Accept" : "application/vnd.github.v3.raw"
        ]
        
        let url:String = "\(Constants.API_URL)repos/\(owner)/\(repo)/readme"
        
        //request url
        self.repositoryRequest(.GET, url: url, headers: headers)
    }
    
    // MARK: - Almofire request for Organizations
    private func repositoryRequest(method : Alamofire.Method,url: URLStringConvertible, headers:[String: String]){
        
        Alamofire.request(method, url, encoding : .JSON, headers:headers)
            .responseString(completionHandler: { response in
                
                if self.requestType == .RepoReadMe {
                    
                    var dict = Dictionary<String, AnyObject>()
                    dict["readme"] = "\(response.result.value!)"
                    
                    //Call delegate Success method
                    self.delegate?.succesRepository(self.requestType,result: dict)
                    return
                }
            })
            .responseJSON { response in
                #if DEBUG
                    print("\(response.request)")  // original URL request
                    print("\(response.response)") // URL response
                    print("\(response.result)")   // result of response serialization
                #endif
                
                if self.requestType == .RepoDetail {
                    
                    //Check for failure
                    guard response.result.isSuccess else{
                        
                        //Call delegate Error method
                        self.delegate?.failRepository(self.requestType,error: response.result.error)
                        return
                    }
                    
                    if let result : Dictionary<String, AnyObject> = response.result.value! as? Dictionary<String, AnyObject>{
                        
                        //Check for Authentication error
                        guard result["message"] == nil else  {
                            
                            //Call delegate Error method
                            self.delegate?.failRepository(self.requestType,error: NSError(domain: "com.GHAPIDemo", code: 12345, userInfo: ["message" : result["message"]!]))
                            return
                        }
                        
                        //Call delegate Success method
                        self.delegate?.succesRepository(self.requestType,result: result)
                    }
                }
        }
    }
}