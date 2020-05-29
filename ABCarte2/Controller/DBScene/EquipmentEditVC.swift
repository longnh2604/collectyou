//
//  EquipmentEditVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/02/28.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

class EquipmentEditVC:UIViewController,CanEditDatabaseObject {
    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentEquipment != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentEquipment:BedData? {
        get { return currentObject as? BedData }
        set { currentObject = newValue }
    }
    var onReloadData: (() -> ())?
    var onEditingBegan:(()->())?
    var onEditingEnded:((Object?)->())?
    var isNewObject:Bool = false {
        didSet {
            switchNewObjectMode()
        }
    }
    var selectedCategory:DatabaseManager<RoomData, BedData>.CategoryInfo?
    private var isEdited = false
    @IBOutlet weak var tfEquipmentName: UITextField!
    @IBOutlet weak var tvNote: UITextView!
    @IBOutlet weak var tfIndex: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        tvNote.layer.cornerRadius = 5
        tvNote.delegate = self
    }
    
    //MARK: - functions
    private func switchNewObjectMode() {
        if isNewObject {
            saveButton.setTitle("新規作成", for:.normal)
            cancelButton.isEnabled = true
            deleteButton.isHidden = true
        }
        else {
            saveButton.setTitle("更新する", for:.normal)
            cancelButton.isEnabled = false
            deleteButton.isHidden = false
        }
    }
    private func deactivateInputs() {
        tfEquipmentName.text = ""
        tvNote.text = ""
        tfIndex.text = ""
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        guard let equipment = currentEquipment else { return }
        tfEquipmentName.text = equipment.bed_name
        tvNote.text = equipment.note
        tfIndex.text = String(equipment.display_num)
        scrollView.alpha = 1
        scrollView.isUserInteractionEnabled = true
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    private func startEditing() {
        if isEdited {
            return
        } else {
            isEdited = true
            saveButton.isEnabled = true
            cancelButton.isEnabled = true
            onEditingBegan?()
        }
    }
    @IBAction func bedNameTextFieldChange(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let equipmentNameText = tfEquipmentName.text, equipmentNameText != "" else {
            showCantSaveAlert(message:"設備名を入力して下さい。", completion:{ self.tfEquipmentName.becomeFirstResponder() })
            return
        }

        guard let currentEquipment = currentEquipment else { return }
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        let dict : [String : Any?] = ["bed_name" : equipmentNameText,
                                      "note" : tvNote.text,
                                      "account_id" : accountID,
                                      "display_num": tfIndex.text]
        RealmServices.shared.update(currentEquipment, with: dict)

        if isNewObject {
            APIRequest.onAddNewBed(accID: currentEquipment.account_id, bed: currentEquipment) { (status) in
                if status == 1 {
                    self.onUpdateRealm(currentEquipment: currentEquipment)
                    self.onReloadData?()
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                SVProgressHUD.dismiss()
            }
        } else {
            APIRequest.onUpdateBed(bed: currentEquipment, completion: { (success) in
                if success {
                    self.onUpdateRealm(currentEquipment: currentEquipment)
                    self.onReloadData?()
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                SVProgressHUD.dismiss()
            })
        }
    }
    private func onUpdateRealm(currentEquipment:BedData) {
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        setValueToCurrentObject(accountID,                      forKey:"account_id")
        setValueToCurrentObject(tfEquipmentName.text,        forKey:"bed_name") // to be checed
        setValueToCurrentObject(tvNote.text,                   forKey:"note")
        setValueToCurrentObject(tfIndex.text,          forKey: "display_num")
        currentEquipment.updateUpdated()
        onEditingEnded?(currentEquipment)
        
        isEdited = false
        view.endEditing(true)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentEquipment = currentEquipment else { return }
        RealmServices.shared.saveObjects(objs:currentEquipment) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentEquipment, with:[key:value])
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        isEdited = false
        if isNewObject {
            currentObject = nil
            onEditingEnded?(nil)
            return
        }
        onEditingEnded?(currentObject)
    }
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        showDeletionAlert()
    }
    private func showDeletionAlert() {
        let alert = UIAlertController(title:nil, message:"スタッフ『\(currentEquipment?.bed_name ?? "")』を削除します。この操作は取り消せません。", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentEquipment))
        alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
        present(alert, animated:true, completion:nil)
    }
    private func deleteCurrentEquipment(alert:UIAlertAction) {
        guard let deleteEquipment = currentEquipment else { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        //API handler
        APIRequest.onDeleteBed(bedID: deleteEquipment.id, completion: { (success) in
            if success {
                RealmServices.shared.delete(deleteEquipment)
                self.currentObject = nil
                self.onReloadData?()
            } else {
                self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
            SVProgressHUD.dismiss()
        })
    }
    private func showCantSaveAlert(message:String, completion:(()->())?=nil) {
        let alert = UIAlertController(title:"保存できません", message:message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"閉じる", style:.cancel, handler:{ (action) in completion?() }))
        present(alert, animated:true, completion:nil)
    }
}

extension EquipmentEditVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        startEditing()
    }
}
