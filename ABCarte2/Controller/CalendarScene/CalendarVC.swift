//
//  CalendarVC.swift
//  ABCarte2
//
//  Created by Long on 2018/12/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import LGButton

enum Sort {
    case ascending
    case descending
}

class CalendarVC: BaseVC {

    //Variable
    var cartes: Results<CarteData>!
    var cartesData : [CarteData] = []
    var cartesDay: [CarteData] = []
    var dateEvents: [String] = []
    var treeData : [AccTreeData] = []
    let shopDropMenu = DropDown()
    let yearDropMenu = DropDown()
    let monthDropMenu = DropDown()
    let dayDropMenu = DropDown()
    var currentY : Int?
    var currentM : Int?
    var currentD : Int?
    var currentShop : String?
    var currentShopID : Int?
    var currentDate: Date?
    var sortState: Sort?
    var currentSelected: Int?
    var currentColor: UIColor?
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    //IBOutlet
    @IBOutlet weak var viewCalendar: FSCalendar!
    @IBOutlet weak var tblVisitHistory: UITableView!
    @IBOutlet weak var viewHistory: UIView!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var lblDate: RoundLabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var btnTimeSort: LGButton!
    @IBOutlet weak var btnStaffSort: LGButton!
    @IBOutlet weak var btnEquipmentSort: LGButton!
    @IBOutlet weak var btnShopSelect: LGButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupDropDowns()
    }
    
    private func setupLayout() {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    
        viewCalendar.delegate = self
        viewCalendar.dataSource = self
        viewCalendar.allowsMultipleSelection = false
        viewCalendar.locale = Locale(identifier: "ja")
        viewCalendar.placeholderType = .none
        //register nib
        let nib = UINib(nibName: "HistoryCell", bundle: nil)
        tblVisitHistory.register(nib, forCellReuseIdentifier: "HistoryCell")
        
        tblVisitHistory.delegate = self
        tblVisitHistory.dataSource = self
        tblVisitHistory.tableFooterView = UIView()
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        localizeLanguage()
        checkCondition()
        bottomPanelView.deactiveBottomPanelButtons()
    }
    
    private func checkCondition() {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteTime.rawValue) {
            btnTimeSort.isHidden = false
        }
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kStaffManagement.rawValue) {
            btnStaffSort.isHidden = false
        }
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kBedManagement.rawValue) {
            btnEquipmentSort.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        currentY = nil
        currentM = nil
        currentD = nil
        currentDate = nil
        dateEvents.removeAll()
        cartesDay.removeAll()
        cartesData.removeAll()
        tblVisitHistory.reloadData()
    }
    
    fileprivate func localizeLanguage() {
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Calendar", comment: "")
        lblDate.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Date", comment: "")
        lblDay.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Day", comment: "")
        lblMonth.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Month", comment: "")
        lblYear.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Year", comment: "")
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func loadData() {
        let currDate = Date()
        loadCarteDataByMonth(date: currDate) { (success) in
            if success {
                self.loadCarteDataBySelectedDate(date: currDate)
                self.checkNextDay()
            }
        }
        //select today date
        viewCalendar.select(currDate, scrollToDate: true)
        convertDateAndDisplay(date: currDate)
        updateDropDown()
    }
    
    func loadCarteDataByMonth(date:Date,completion:@escaping(Bool) -> ()) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let monthYear = dateFormatter.string(from: date)
      
        APIRequest.getCustomerCartesByMonth(accID: currentShopID, month: monthYear) { (success) in
            if success {
                self.cartes = self.realm.objects(CarteData.self)
                
                self.cartesData.removeAll()
                self.dateEvents.removeAll()
                
                for i in 0 ..< self.cartes.count {
                    self.cartesData.append(self.cartes[i])
                    self.dateEvents.append(self.cartes[i].date_converted)
                }
                //refresh ViewCalendar
                self.viewCalendar.reloadData()
                completion(true)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                completion(false)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func loadCarteDataBySelectedDate(date:Date) {
        let dateString = self.dateFormatter.string(from: date)
        cartesDay.removeAll()
        for i in 0 ..< self.cartes.count {
            if cartes[i].date_converted == "\(dateString)" {
                cartesDay.append(cartes[i])
            }
        }
        onSorting(self.btnTimeSort)
    }
    
    private func convertDateAndDisplay(date:Date) {
        currentDate = date

        let calendar = Calendar.current
        self.currentY = calendar.component(.year, from: date)
        self.currentM = calendar.component(.month, from: date)
        self.currentD = calendar.component(.day, from: date)
        
        self.btnYear.setTitle(String(self.currentY!), for: .normal)
        self.btnMonth.setTitle(String(self.currentM!), for: .normal)
        self.btnDay.setTitle(String(self.currentD!), for: .normal)
    }
    
    private func checkNextDay() {
        let dateString = self.dateFormatter.string(from: Date.tomorrow)
        
        for i in 0 ..< dateEvents.count {
            if dateEvents[i] == dateString {
                var cusName = ""
                
                for j in 0 ..< cartesData.count {
                    if cartesData[j].date_converted == dateString {
                        if cusName != "" {
                            cusName.append(", ")
                        }
                        cusName.append(cartesData[j].cus[0].last_name + cartesData[j].cus[0].first_name)
                    }
                }
                sendTomorrowEvent(cus: cusName)
                return
            }
        }
    }
    
    private func sendTomorrowEvent(cus: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "来店予約"
        content.body = "明日の来店御客名は\(cus)"
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "TomorrowEvent", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func setupDropDowns() {
        //year
        yearDropMenu.anchorView = btnYear
        yearDropMenu.bottomOffset = CGPoint(x: 0, y: btnYear.bounds.height)
        
        yearDropMenu.dataSource = [
            "2010",
            "2011",
            "2012",
            "2013",
            "2014",
            "2015",
            "2016",
            "2017",
            "2018",
            "2019",
            "2020",
            "2021",
            "2022",
            "2023",
            "2024",
            "2025",
            "2026",
            "2027",
            "2028",
            "2029",
            "2030"
        ]
        
        //month
        monthDropMenu.anchorView = btnMonth
        monthDropMenu.bottomOffset = CGPoint(x: 0, y: btnMonth.bounds.height)
        
        monthDropMenu.dataSource = [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12"
        ]
        
        //day
        dayDropMenu.anchorView = btnDay
        dayDropMenu.bottomOffset = CGPoint(x: 0, y: btnDay.bounds.height)
        
        dayDropMenu.dataSource = [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "23",
            "24",
            "25",
            "26",
            "27",
            "28",
            "29",
            "30",
            "31"
        ]
        
        //shop
        shopDropMenu.anchorView = btnShopSelect
        shopDropMenu.bottomOffset = CGPoint(x: 0, y: btnShopSelect.bounds.height)
        
        var shopArr = [String]()
        //append main shop
        shopArr.append(treeData[0].acc_name)
        btnShopSelect.titleString = treeData[0].acc_name
        currentShop = treeData[0].acc_name
        currentShopID = treeData[0].id
        if treeData[0].children.count > 0 {
            for i in 0 ..< treeData[0].children.count {
                shopArr.append(treeData[0].children[i].acc_name)
            }
            shopArr.append("全店表示")
        }
        shopDropMenu.dataSource = shopArr
    }
    
    fileprivate func updateDropDown() {
        //select current year
        for i in 0 ..< yearDropMenu.dataSource.count {
            if yearDropMenu.dataSource[i].contains(String(self.currentY!)) {
                yearDropMenu.selectRow(i, scrollPosition: .middle)
            }
        }
        
        yearDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnYear.setTitle(item, for: .normal)
            self?.currentY = Int(item)
            self?.updateSelectedDate()
        }
        //select current month
        for i in 0 ..< monthDropMenu.dataSource.count {
            if monthDropMenu.dataSource[i].contains(String(self.currentM!)) {
                monthDropMenu.selectRow(i, scrollPosition: .middle)
            }
        }
        
        monthDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnMonth.setTitle(item, for: .normal)
            self?.currentM = Int(item)
            self?.updateSelectedDate()
        }
        //select current month
        for i in 0 ..< dayDropMenu.dataSource.count {
            if dayDropMenu.dataSource[i].contains(String(self.currentD!)) {
                dayDropMenu.selectRow(i, scrollPosition: .middle)
            }
        }
        
        dayDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnDay.setTitle(item, for: .normal)
            self?.currentD = Int(item)
            self?.updateSelectedDate()
        }
        //select current shop
        for i in 0 ..< shopDropMenu.dataSource.count {
            if shopDropMenu.dataSource[i].contains(String(self.currentShop!)) {
                shopDropMenu.selectRow(i, scrollPosition: .middle)
            }
        }
        
        shopDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnShopSelect.titleString = item
            self?.currentShop = item
            //check if main shop or not
            if index == 0 {
                self?.currentShopID = self?.treeData[0].id
            } else if index == (self?.treeData[0].children.count)! + 1 {
                self?.currentShopID = nil
            } else {
                self?.currentShopID = self?.treeData[0].children[index-1].id
            }
            self?.updateSelectedDate()
            
            guard let currentDate = self?.currentDate else { return }
            self?.loadCarteDataByMonth(date: currentDate) { (success) in
                if success {
                    self?.loadCarteDataBySelectedDate(date: currentDate)
                }
            }
        }
    }
    
    private func updateSelectedDate() {
        //remove selected date
        for date in self.viewCalendar.selectedDates {
            self.viewCalendar.deselect(date)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: "\(currentY!)-\(currentM!)-\(currentD!)") {
            self.viewCalendar.select(date, scrollToDate: true)
            self.calendar(self.viewCalendar, didSelect: date, at: .current)
        }
    }
    
    private func changeButtonSortStatus(enable:Bool,selected:Int,button:LGButton) {
        if enable {
            if currentSelected == selected {
                switch sortState {
                case .ascending:
                    button.bgColor = COLOR_SET.kBLUE
                    sortState = .descending
                    button.rightImageSrc = UIImage(named: "icon_sort_ascending.png")
                case .descending:
                    button.bgColor = COLOR_SET.kPENSELECT
                    sortState = .ascending
                    button.rightImageSrc = UIImage(named: "icon_sort_descending.png")
                default:
                    break
                }
            } else {
                button.bgColor = COLOR_SET.kPENSELECT
                sortState = .ascending
                button.rightImageSrc = UIImage(named: "icon_sort_descending.png")
            }
        } else {
            button.bgColor = UIColor.lightGray
            button.rightImageSrc = UIImage(named: "icon_sort_descending.png")
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onShopChanged(_ sender: LGButton) {
        shopDropMenu.show()
    }
    
    @IBAction func onSelectDate(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            yearDropMenu.show()
        case 2:
            monthDropMenu.show()
        case 3:
            dayDropMenu.show()
        default:
            break
        }
    }
    
    @IBAction func onSorting(_ sender: LGButton) {
        switch sender.tag {
        case 1:
            changeButtonSortStatus(enable: true, selected: sender.tag, button: btnTimeSort)
            changeButtonSortStatus(enable: false, selected: sender.tag, button: btnStaffSort)
            changeButtonSortStatus(enable: false, selected: sender.tag, button: btnEquipmentSort)
            switch sortState {
            case .ascending:
                cartesDay = cartesDay.sorted(by: { $0.select_date < $1.select_date })
            case .descending:
                cartesDay = cartesDay.sorted(by: { $0.select_date > $1.select_date })
            case .none:
                break
            }
            for i in 0 ..< cartesDay.count {
                try! realm.write {
                    cartesDay[i].carte_mark = 0
                }
            }
        case 2:
            changeButtonSortStatus(enable: false, selected: sender.tag, button: btnTimeSort)
            changeButtonSortStatus(enable: true, selected: sender.tag, button: btnStaffSort)
            changeButtonSortStatus(enable: false, selected: sender.tag, button: btnEquipmentSort)
            switch sortState {
            case .ascending:
                cartesDay = cartesDay.sorted(by: { $0.select_date < $1.select_date })
                cartesDay = cartesDay.sorted(by: { $0.staff_name < $1.staff_name })
            case .descending:
                cartesDay = cartesDay.sorted(by: { $0.select_date < $1.select_date })
                cartesDay = cartesDay.sorted(by: { $0.staff_name > $1.staff_name })
            case .none:
                break
            }
            for i in 0 ..< cartesDay.count {
                if i > 0 {
                    if cartesDay[i].staff_name != cartesDay[i - 1].staff_name {
                        try! realm.write {
                            if cartesDay[i - 1].carte_mark == 0 {
                                cartesDay[i].carte_mark = 1
                            } else {
                                cartesDay[i].carte_mark = 0
                            }
                        }
                    } else {
                        try! realm.write {
                            cartesDay[i].carte_mark = cartesDay[i - 1].carte_mark
                        }
                    }
                }
            }
        case 3:
            changeButtonSortStatus(enable: false, selected: sender.tag, button: btnTimeSort)
            changeButtonSortStatus(enable: false, selected: sender.tag, button: btnStaffSort)
            changeButtonSortStatus(enable: true, selected: sender.tag, button: btnEquipmentSort)
            switch sortState {
            case .ascending:
                cartesDay = cartesDay.sorted(by: { $0.select_date < $1.select_date })
                cartesDay = cartesDay.sorted(by: { $0.bed_name < $1.bed_name })
            case .descending:
                cartesDay = cartesDay.sorted(by: { $0.select_date < $1.select_date })
                cartesDay = cartesDay.sorted(by: { $0.bed_name > $1.bed_name })
            case .none:
                break
            }
            for i in 0 ..< cartesDay.count {
                if i > 0 {
                    if cartesDay[i].bed_name != cartesDay[i - 1].bed_name {
                        try! realm.write {
                            if cartesDay[i - 1].carte_mark == 0 {
                                cartesDay[i].carte_mark = 1
                            } else {
                                cartesDay[i].carte_mark = 0
                            }
                        }
                    } else {
                        try! realm.write {
                            cartesDay[i].carte_mark = cartesDay[i - 1].carte_mark
                        }
                    }
                }
            }
        default:
            break
        }
        
        currentSelected = sender.tag
        tblVisitHistory.reloadData()
    }
}

//*****************************************************************
// MARK: - FSCalendar Delegate
//*****************************************************************

extension CalendarVC: FSCalendarDelegate, FSCalendarDataSource,FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        
        if self.dateEvents.contains(dateString) {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let key = self.dateFormatter.string(from: date)
        if self.dateEvents.contains(key) {
            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let key = self.dateFormatter.string(from: date)
        return dateEvents.contains(key) ? UIImage(named: "icon_carte_color") : nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if currentDate != date {
            currentSelected = nil
        }
        convertDateAndDisplay(date: date)
        loadCarteDataBySelectedDate(date: date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        loadCarteDataByMonth(date: calendar.currentPage) { (success) in
            if success {
                if let currD = self.currentDate {
                    calendar.deselect(currD)
                }
                self.cartesDay.removeAll()
                self.tblVisitHistory.reloadData()
            }
        }
    }
}

//*****************************************************************
// MARK: - Tableview Delegate
//*****************************************************************

extension CalendarVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartesDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryCell else
        { return UITableViewCell() }
        let his = cartesDay[indexPath.row]
        cell.configure(data: his)
        cell.btnDetail.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

//*****************************************************************
// MARK: - HistoryCell Delegate
//*****************************************************************

extension CalendarVC: HistoryCellDelegate {
    
    func onSelectDetail(index: Int) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Carte", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "CarteListVC") as? CarteListVC {
            if let navigator = navigationController {
                viewController.customer = copyCustomerData(subData: cartesDay[index].cus[0])
                viewController.accounts = self.accounts
                viewController.carteID = cartesDay[index].id
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func copyCustomerData(subData:SubCustomerData) -> CustomerData {
        let new = CustomerData()
        
        new.id = subData.id
        new.fc_account_id = subData.fc_account_id
        new.fc_account_account_id = subData.fc_account_account_id
        new.first_name = subData.first_name
        new.last_name = subData.last_name
        new.first_name_kana = subData.first_name_kana
        new.last_name_kana = subData.last_name_kana
        new.gender = subData.gender
        new.bloodtype = subData.bloodtype
        new.customer_no = subData.customer_no
        
        if subData.pic_url == "" {
            new.pic_url = subData.pic_url
            new.thumb = new.pic_url
        } else {
            new.pic_url = subData.pic_url
            
            let linkPath = (subData.pic_url as NSString).deletingLastPathComponent
            let lastPath = (subData.pic_url as NSString).lastPathComponent
            
            new.thumb = "\(linkPath)/thumb_\(lastPath)"
        }
        
        new.birthday = subData.birthday
        new.hobby = subData.hobby
        new.email = subData.email
        new.postal_code = subData.postal_code
        new.address1 = subData.address1
        new.address2 = subData.address2
        new.address3 = subData.address3
        new.responsible = subData.responsible
        new.mail_block = subData.mail_block
        new.first_daycome = subData.first_daycome
        new.last_daycome = subData.last_daycome
        new.update_date = subData.update_date
        new.urgent_no = subData.urgent_no
        new.memo1 = subData.memo1
        new.memo2 = subData.memo2
        new.created_at = subData.created_at
        new.updated_at = subData.updated_at
        new.selected_status = 0
        new.cus_status = subData.cus_status
        return new
    }
}

//*****************************************************************
// MARK: - UserNotificationCenter Delegate
//*****************************************************************

extension CalendarVC: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
}
