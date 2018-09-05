//
//  NoteEditItemViewModel.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//


import Foundation
import UIKit
//create our view model
class NoteEditItemViewModel {
    
    let content: String
    private let titleAttribute = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22) ]
    init(with content: String) {
        self.content = content
    }
    var attributedString: NSAttributedString {
        get {
            var output: NSAttributedString
            if let positionOfLineBreak = content.range(of: "\n", options: .literal, range: content.startIndex..<content.endIndex)?.lowerBound {
                let title: String = String(content[..<positionOfLineBreak])
                if positionOfLineBreak < content.endIndex {
                    let subtitle = String(content[positionOfLineBreak...])
                    let title = NSAttributedString(string: title, attributes: titleAttribute)
                    let result = NSMutableAttributedString()
                    result.append(title)
                    result.append(NSAttributedString(string: subtitle))
                    output = result
                } else {
                    output = NSAttributedString(string: title, attributes: titleAttribute)
                }
            } else {
                output = NSAttributedString(string: content, attributes: titleAttribute)
            }
            return output
        }
    }
}
