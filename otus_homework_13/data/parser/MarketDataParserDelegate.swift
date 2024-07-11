//
//  MarketDataParserDelegate.swift
//  otus_homework_13
//
//  Created by Поляков Станислав Денисович on 11.07.2024.
//

import Foundation

class MarketDataParserDelegate: NSObject, XMLParserDelegate {
    private var isValueProcessing: Bool = false
    private(set) var values: [Double] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName.lowercased() {
            case "value": isValueProcessing = true
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName.lowercased() {
            case "value" : isValueProcessing = false
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !isValueProcessing { return }
        
        values.append(
            Double(
                string
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(of: ",", with: ".")
            )!
        )
    }
}
