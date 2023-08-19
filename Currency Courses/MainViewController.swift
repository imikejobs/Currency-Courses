//
//  ViewController.swift
//  Currency Courses
//
//  Created by Mike on 07/01/2023.
//  Copyright © 2023 Mike. All rights reserved.
//

import Cocoa

class CurrencyCell: NSTableCellView {
    @IBOutlet weak var labelName: NSTextField!
    @IBOutlet weak var labelCourse: NSTextField!
    @IBOutlet weak var imageCurrency: NSImageView!

    var currency: Currency!
    func initCell(currency: Currency) {
        labelName.stringValue = currency.name
        labelCourse.stringValue = "\(currency.nominal) \(currency.code) = \(currency.value) RUB"
        
        imageCurrency.image = currency.image
    }
}

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var labelDate: NSTextField!
    
   
    @IBOutlet weak var buttonRefresh: NSButton!
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(pathForSaveXML)
        //loadCurrencies()
        parseCurrencies()
        
        labelDate.stringValue = "Курсы за дату: \(dateForCourses)"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let cgr = NSClickGestureRecognizer(target: self, action: #selector(clickOnDate))
        labelDate.addGestureRecognizer(cgr)
        NotificationCenter.default.addObserver(forName: nCoursesLoaded, object: nil, queue: OperationQueue.main) { (notification) in
            self.labelDate.stringValue = "Курсы за дату: \(dateForCourses)"
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: nStartLoaded, object: nil, queue: OperationQueue.main) { (notification) in
            self.indicator.startAnimation(nil)
            self.buttonRefresh.isHidden = true
        }
        NotificationCenter.default.addObserver(forName: nXMLLoaded, object: nil, queue: OperationQueue.main) { (notification) in
            self.indicator.stopAnimation(nil)
            self.indicator.isDisplayedWhenStopped = false
            self.buttonRefresh.isHidden = false
            }
        parseCurrencies()
        
        // Do any additional setup after loading the view.
    }
    
    @objc
    func clickOnDate() {
        performSegue(withIdentifier: "goToDate", sender: self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currenciesForShow.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("Cell"), owner: self) as? CurrencyCell {
            let currencyForCell = currenciesForShow[row]
            cell.initCell(currency: currencyForCell)
            return cell
        }
        return nil
    }
   
    @IBAction func pushRefreshAction(_ sender: Any) {
        loadCurrencies(for: Date())
    }
    @IBAction func pushExitAction(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

}

