//
//  ConverterViewController.swift
//  Currency Courses
//
//  Created by Mike on 14/01/2023.
//  Copyright © 2023 Mike. All rights reserved.
//

import Cocoa

class ConverterViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var labelDate: NSTextField!
    @IBOutlet weak var popUpFROM: NSPopUpButton!
    @IBOutlet weak var popUpTO: NSPopUpButton!
    @IBOutlet weak var textFROM: NSTextField!
    @IBOutlet weak var textTO: NSTextField!
    @IBAction func popUpFromAction(_ sender: Any) {
        currencyFrom = currenciesForShow[popUpFROM.indexOfSelectedItem]
        showResult()
    }
    @IBAction func popUpToAction(_ sender: Any) {
        currencyTo = currenciesForShow[popUpTO.indexOfSelectedItem]
        showResult()
    }
    @IBAction func textFromAction(_ sender: Any) {
        showResult()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.labelDate.stringValue = "Курс за дату: \(dateForCourses)"
        
        popUpFROM.removeAllItems()
        popUpTO.removeAllItems()

        for item in currenciesForShow {
            popUpFROM.addItem(withTitle: item.name)
            popUpTO.addItem(withTitle: item.name)
           

        }
        currencyFrom = currenciesForShow[0]
        currencyTo = currenciesForShow[0]
        
        textFROM.delegate = self
        
    }
    var currencyFrom: Currency!
    var currencyTo: Currency!
    
    override func viewDidAppear() {
        self.view.window?.title = "Конвертер"
    }
    
    func controlTextDidChange(_ obj: Notification) {
        showResult()
    }
    
    func showResult() {
        if let summ = Double(textFROM.stringValue) {
            textTO.stringValue = convert(fromCurrency: currencyFrom, toCurrency: currencyTo, summ: summ)
        } else {
            textTO.stringValue = "-"
        }
    }
}
