//
//  DateViewController.swift
//  Currency Courses
//
//  Created by Mike on 14/01/2023.
//  Copyright © 2023 Mike. All rights reserved.
//

import Cocoa

class DateViewController: NSViewController {
    @IBOutlet weak var datePicker: NSDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        if let date = df.date(from: dateForCourses) {
            datePicker.dateValue = date
        } else {
            datePicker.dateValue = Date()
        }
        
    }
    @IBAction func datePickerAction(_ sender: Any) {
        loadCurrencies(for: datePicker.dateValue)
        self.dismiss(nil)
    }
    
}
