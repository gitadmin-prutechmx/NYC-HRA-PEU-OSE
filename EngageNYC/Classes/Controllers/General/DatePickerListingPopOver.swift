

import UIKit

protocol UpdateSelectedDateDelegate{
    func didSelectDate(selectedDate :Date, forType: DateTimePickerType)
}


enum DateTimePickerType {
    case from
    case to
}

/// UIViewController that is presented as a popover to display a date picker - to select a Due-date for creating tasks
class DatePickerListingPopOver: UIViewController {

    var delegate:UpdateSelectedDateDelegate?
    var pickeType: DateTimePickerType?
    
//    var eventDate : Date?
//    var minTime : Date?
    @IBOutlet weak var btnToday: UIButton!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        datePicker.addTarget(self, action: #selector(datePickerChanged),
                             for: .valueChanged)
        
//        if pickeType != nil{
//
//            if parentType! == .createTouchPoint {
//                datePicker.datePickerMode = .time
//                datePicker.minuteInterval = 15
//
//                if eventDate != nil{
//                    datePicker.setDate(eventDate!, animated: true)
//                }
//                if minTime != nil{
//                    datePicker.minimumDate = minTime!
//                }
//            }
//            else if parentType! == .tmCreateTouchPoint{
//                datePicker.datePickerMode = .dateAndTime
//                datePicker.minuteInterval = 15
//
//                if eventDate != nil{
//                    datePicker.setDate(eventDate!, animated: true)
//                }
//            }
//            else if parentType! == .onlyDate{
//                datePicker.datePickerMode = .date
//                if eventDate != nil{
//                    datePicker.setDate(eventDate!, animated: true)
//                }
//            }
//        }
//
//        else{
//
//            if eventDate != nil{
//                datePicker.date = eventDate!
//            }
//            else {
//                datePicker.date = Date()
//            }
//
//            datePicker.minimumDate = Date()
//        }
        
    }

    @objc func datePickerChanged(datePicker:UIDatePicker) {
        delegate?.didSelectDate(selectedDate: datePicker.date, forType: pickeType!)
    }

    @IBAction func btnTodayClick(_ sender: Any)
    {
        delegate?.didSelectDate(selectedDate: Date(), forType: pickeType!)
         self.dismiss(animated: true, completion: nil)
    }
}
