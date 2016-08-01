//
//  MarkDownTextView.swift
//  GitHubAPIDemo
//
//  Created by Nignesh on 2016-07-31.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import UIKit

class MarkDownTextView: UITextView {

    var markdownText: NSString? {
        didSet {
            
            if markdownText == nil || markdownText == "" {
                attributedText = NSAttributedString(string: "")
                return
            }
            
            // markdown attaribute text
            var markdownEngine = Markdown()
            let informationHTML = markdownEngine.transform(markdownText! as String)
            let informationData = informationHTML.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            do {
                let informationString = try NSAttributedString(data: informationData!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                attributedText = informationString
                
            } catch {
                print(error)
                return
            }
        }
    }
}

