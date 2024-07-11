//
//  CurrencyParser.swift
//  otus_homework_13
//
//  Created by Поляков Станислав Денисович on 11.07.2024.
//

import Foundation

class CurrencyParserDelegate: NSObject, XMLParserDelegate {
    private var currentTitle: String?
    private var currentCode: String?
    private(set) var currencies: [CurrencyResponse] = []
    
    private var isItemProccessing: Bool = false {
        didSet {
            if !isCodeProcessing {
                guard let title = currentTitle, let code = currentCode else { return }
                currencies.append(CurrencyResponse(title: title, code: code))
                
                currentTitle = nil
                currentCode = nil
            }
        }
    }
    private var isTitleProccessing: Bool = false
    private var isCodeProcessing: Bool = false
    
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName.lowercased() {
            case "item":
                isItemProccessing = true
            case "name":
                isTitleProccessing = true
            case "parentcode":
                isCodeProcessing = true
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName.lowercased() {
            case "item":
                isItemProccessing = false
            case "name":
                isTitleProccessing = false
            case "parentcode":
                isCodeProcessing = false
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !isItemProccessing { return }
        if !isTitleProccessing && !isCodeProcessing { return }
        
        let value = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if isTitleProccessing {
            currentTitle = value
        } else if isCodeProcessing {
            currentCode = value
        }
    }
}
