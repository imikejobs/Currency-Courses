//
//  SettingsViewController.swift
//  Currency Courses
//
//  Created by Mike on 16/01/2023.
//  Copyright © 2023 Mike. All rights reserved.
//

import Cocoa

class SettingsCell: NSTableCellView {
    @IBOutlet weak var checkBox: NSButton!
    
    var currency: Currency!
    func initCell(currency: Currency) {
        self.currency = currency
        checkBox.title = currency.name
        if checkCurrencyInList(code: currency.code) {
            checkBox.state = .on
        } else {
            checkBox.state = .off
        }
        
    }
    @IBAction func chechBoxAction(_ sender: Any) {
        if checkBox.state == .on {
            addCurrencyToList(code: currency.code)
        } else {
            removeCurrencyFromList(code: currency.code )
        }
        NotificationCenter.default.post(name: nCoursesLoaded, object: nil)
    }
    
}

class SettingsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear() {
        self.view.window?.title = "Настройки"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currencies.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("Cell"), owner: self) as? SettingsCell {
            let currency = currencies[row]
            cell.initCell(currency: currency)
            return cell
        }
        return nil
    }
}
