//
//  TimeScreenViewController.swift
//  Weather.io
//
//  Created by Aaron on 2/12/15.
//  Copyright © 2019 Team 35. All rights reserved.
//

import UIKit
import WebKit

class TimeScreenViewController: UIViewController, WKUIDelegate{
    
    let Datepicker = UIDatePicker(frame: CGRect(x:50, y:50, width:300, height:300))
    let Timepicker = UIDatePicker(frame: CGRect(x:50, y:320, width:300, height:300))

    var DateString = String("NULL")
    var TimeString = String("NULL")
        
    //START WEB VIEW
    @IBOutlet weak var web: UIWebView!
    @IBAction func BackFromTime(_ sender: Any) {
        self.performSegue(withIdentifier: "BackFromTime", sender: self)
    }
    
    @IBAction func SendData(_ sender: Any) {
        //GRAB TEXT FROM FILE
        let file = "Location.txt"
        var text2 = "nothing"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                text2 = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {/* error handling here */}
            var urlstring = "http://192.168.43.63/"
            //var urlstring = "http://172.20.10.5/"
            print(text2)
            urlstring = urlstring + text2 + "dat=" + DateString + "tim=" + TimeString
            print(urlstring)
            let myURL = URL(string: urlstring)
            let myRequest = URLRequest(url: myURL!)
            web.loadRequest(myRequest)
        }
    }
    
    @objc func DatepickerChanged(picker: UIDatePicker) {
        DateString = DateFormatterThing(x: 1)
    }
    @objc func TimepickerChanged(picker: UIDatePicker) {
        TimeString = TimeFormatterThing(x: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Datepicker.datePickerMode = UIDatePicker.Mode.date
        Datepicker.minimumDate = Date()
        Datepicker.maximumDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: 5, to: Date())
        Datepicker.setValue(UIColor.white, forKeyPath: "textColor")
        Datepicker.addTarget(self, action: #selector(DatepickerChanged(picker:)), for: .valueChanged)
        self.view.addSubview(Datepicker)
        
        Timepicker.setValue(UIColor.white, forKeyPath: "textColor")
        Timepicker.datePickerMode = UIDatePicker.Mode.time
        Timepicker.setDate(Date(), animated: true)
        Timepicker.addTarget(self, action: #selector(TimepickerChanged(picker:)), for: .valueChanged)
        self.view.addSubview(Timepicker)
        
        //SETUP DATE AND TIME STRINGS
        DateString = DateFormatterThing(x: 0)
        TimeString = TimeFormatterThing(x: 0)
    }
    
    func DateFormatterThing(x: Int) -> String {
        //SET DATE FORMAT AND GET STRING
        var y = String("NULL")
        if x == 1
        {
            y = DateFormatter.localizedString(from: Datepicker.date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
        }
        else
        {
            y = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
        }
        //SPLIT THE STRING INTO COMPONENTS
        let g = String(y)
        let ddate = g.components(separatedBy: "/")
        var month = ddate[0]
        var day = ddate[1]
        let year = ddate[2]
        //CHANGE FORMAT OF MONTH AND DAY
        if Int(month)! < 10
        {
            month = "0" + month
        }
        if Int(day)! < 10
        {
            day = "0" + day
        }
        
        return month + "." + day + "." + year
    }
    
    func TimeFormatterThing(x: Int) -> String {
        //SET TIME FORMAT AND GET STRING
        var z = String("NULL")
        if x == 1
        {
            z = DateFormatter.localizedString(from: Timepicker.date, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
        }
        else
        {
            z = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
        }
        let g = String(z)
        //PARSE THE STRING
        let ttime = g.components(separatedBy: ":")
        var hour = ttime[0]
        let rest = ttime[1]
        let rrest = rest.components(separatedBy: " ")
        let min = rrest[0]
        let AMPM = rrest[1]
        //SET SOME WEIRD VALUES FOR 24H CLOCK
        if AMPM == "PM" && hour != String(12)
        {
            hour = String(12 + Int(hour)!)
        }
        else if AMPM == "AM" && hour == String(12)
        {
            hour = String(0)
        }
        if Int(hour)! < 10
        {
            hour = "0" + hour
        }
        
        return (hour + "." + min)
    }
    
}
extension Date {
    var localizedDescription: String {
        return description(with: .current)
    }
}

