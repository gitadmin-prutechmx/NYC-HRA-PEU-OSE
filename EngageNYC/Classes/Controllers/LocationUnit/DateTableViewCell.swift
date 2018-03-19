//
//  FollowUpDateTableViewCell.swift
//  EngageNYCDev
//
//  Created by Kamal on 10/12/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//


@objc protocol DateTableViewCellDelegate {
    
    func selectDate(forDate date: Date)
    @objc optional func clearDate()
}

class DateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var btnToday: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate : DateTableViewCellDelegate?

    
    var frameAdded = false
    
    class var expandHeight:CGFloat{ get {return 316 } }
    class var defaultHeight:CGFloat{ get {return 44 } }
    
    @IBAction func dateTimeChanged(_ sender: Any) {
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        detail.text = dateFormatter.string(from: datePicker.date)
        
        dateDelegate(val: datePicker.date)

    }
    
    @IBAction func btnClearAction(_ sender: UIButton) {
        
        
        detail.text = "Select Date"
        delegate?.clearDate!()
        
    }
    
    @IBAction func btnTodayAction(_ sender: UIButton)
    {
       
      
        datePicker.date = Date()
        
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: todaysDate)
        detail.text = dateString
        
        dateDelegate(val: todaysDate)

    }
    
    func dateDelegate(val :Date){
        if(delegate != nil){
            delegate?.selectDate(forDate:  val)
        }
    }
    
    func checkHeight(){
        datePicker.isHidden = (frame.size.height < DateTableViewCell.expandHeight)
        btnToday.isHidden = (frame.size.height < DateTableViewCell.expandHeight)
    }
    
    func watchFrameChanges() {
        if(!frameAdded){
            addObserver(self , forKeyPath: "frame", options: .new, context: nil )
            frameAdded = true
            checkHeight()
        }
    }
    
    func ignoreFrameChanges() {
        if(frameAdded){
            removeObserver(self, forKeyPath: "frame")
            frameAdded = false
        }
    }
    
    deinit {
        print("deinit called");
        ignoreFrameChanges()
    }
    
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame"{
            checkHeight()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
