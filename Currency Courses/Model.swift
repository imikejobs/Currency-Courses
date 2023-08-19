//
//  Model.swift
//  Currency Courses
//
//  Created by Mike on 07/01/2023.
//  Copyright © 2023 Mike. All rights reserved.
//

import Foundation
import Cocoa

struct Currency {
    var name: String
    var code: String
    var nominal: Double
    var value: Double
    
    static func createRuble() -> Currency {
        return Currency(name: "Российский рубль", code: "RUR", nominal: 1, value: 1)
    }
    var image: NSImage? {
        return NSImage(named: NSImage.Name("\(code).png"))
    }
    
}

var dateForCourses: String = ""
 
var currencies: [Currency] = []

var currenciesForShow: [Currency] {
    var returnValue: [Currency] = []
    for code in codesForShow {
        for currency in currencies {
            if code == currency.code {
                returnValue.append(currency)
            }
        }
    }
    return returnValue
}

var codesForShow: [String] {
    get {
        return UserDefaults.standard.object(forKey: "codesForShow") as? [String] ?? ["RUR", "USD", "EUR"]
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "codesForShow")
        UserDefaults.standard.synchronize()
    }
}

func addCurrencyToList(code: String) {
    codesForShow.append(code)
}

func removeCurrencyFromList(code: String) {
    codesForShow.removeAll { (item) -> Bool in
        if item == code {
            return true
        } else {
            return false
        }
    }
}

func checkCurrencyInList(code: String) -> Bool {
    for item in codesForShow {
        if item == code {
            return true
        }
    }
    return false
}

var strForDownloadCurrency = "http://www.cbr.ru/scripts/XML_daily.asp?date_req="

var pathForSaveXML: String {
    NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/data.xml"
}

func loadCurrencies (for date: Date) {
    let df = DateFormatter()
    df.dateFormat = "dd/MM/yyyy"
    
    var strUrl = strForDownloadCurrency
    let stringDate = df.string(from: date)
    strUrl = strUrl + stringDate
    
    let url = URL(string: strUrl)!
    
    let session = URLSession(configuration: .default)
    
    let task = session.downloadTask(with: url) { (urlFile, responce, error) in
        NotificationCenter.default.post(name: nXMLLoaded, object: nil)
        if error == nil {
            guard let urlFile = urlFile else {
                print("urlFile = nil")
                return
            }
            do {
                _ = try FileManager.default.replaceItemAt(URL(fileURLWithPath: pathForSaveXML), withItemAt: urlFile)
                parseCurrencies()
            } catch {
                print("\(error.localizedDescription)")
            }
        } else {
            print("\(error!.localizedDescription)")
        }
    }
    NotificationCenter.default.post(name: nStartLoaded, object: nil)
    task.resume()
    
}
var nXMLLoaded = NSNotification.Name("nXMLloaded")
var nStartLoaded = NSNotification.Name("nStartLoaded")
var nCoursesLoaded = NSNotification.Name("nCoursesLoaded")
func parseCurrencies() {
    let returnVal = Parser().startToParse()
    currencies = returnVal.currencies
    dateForCourses = returnVal.date
    NotificationCenter.default.post(name: nCoursesLoaded, object: nil )
}

class Parser: NSObject, XMLParserDelegate {
    var currentCourses: [Currency] = []
    var currentCurrency: Currency!
    var dateCurrent: String = ""
    
    var xmlParser: XMLParser!
    func startToParse() -> (currencies:[Currency], date: String) {
        currentCourses = [Currency.createRuble()]
        if FileManager.default.fileExists(atPath: pathForSaveXML) {
            xmlParser = XMLParser(contentsOf: URL(fileURLWithPath: pathForSaveXML))
            xmlParser.delegate = self
            xmlParser.parse()
        }
        return (currentCourses, dateCurrent)
    }
    func parserDidStartDocument(_ parser: XMLParser) {
        //print("parserDidStartDocument")
    }
    
    var currentElement: String = ""
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //print("didStartElement - \(elementName)")
        if elementName == "ValCurs" {
            dateCurrent = attributeDict["Date"] ?? ""
        }
        if elementName == "Valute" {
            currentCurrency = Currency(name: "", code: "", nominal: 0, value: 0)
        }
        if elementName == "CharCode" {
            currentElement = "CharCode"
        }
        if elementName == "Name" {
            currentElement = "Name"
        }
        if elementName == "Value" {
            currentElement = "Value"
        }
        if elementName == "Nominal" {
            currentElement = "Nominal"
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print("foundCharacters - \(string)")

        if currentElement == "CharCode" {
            currentCurrency.code = string
        }
        if currentElement == "Name" {
            currentCurrency.name = string
        }
        if currentElement == "Nominal" {
            currentCurrency.nominal = Double(string) ?? 0
        }
        if currentElement == "Value" {
            currentCurrency.value = Double(string.replacingOccurrences(of: ",", with: ".")) ?? 0
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("didEndElement - \(elementName)")
        if elementName == "Valute" {
            currentCourses.append(currentCurrency)
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        //print("parserDidEndDocument")
        //currencies = currentCourses
    }
}


func convert(fromCurrency: Currency, toCurrency: Currency, summ: Double) -> String {
    let nf = NumberFormatter()
    nf.maximumFractionDigits = 2
    let str = nf.string(from: NSNumber(value: ((fromCurrency.value / fromCurrency.nominal) / (toCurrency.value / toCurrency.nominal) * summ)))
    
    return str ?? "-"
}
