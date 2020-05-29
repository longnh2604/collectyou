//
//  JobEditVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/05/11.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

class JobEditVC:UIViewController,CanEditDatabaseObject {
    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentJob != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentJob:JobData? {
        get { return currentObject as? JobData }
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
    var selectedCategory:DatabaseManager<JobCategoryData, JobData>.CategoryInfo?
    private var isEdited = false
    @IBOutlet weak var tfJobName: UITextField!
    @IBOutlet weak var tfIndex: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        
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
        tfJobName.text = ""
        tfIndex.text = ""
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        guard let job = currentJob else { return }
        tfJobName.text = job.job
        tfIndex.text = String(job.display_num)
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
    @IBAction func jobNameTextFieldChange(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let jobNameText = tfJobName.text, jobNameText != "" else {
            showCantSaveAlert(message:"設備名を入力して下さい。", completion:{ self.tfJobName.becomeFirstResponder() })
            return
        }

        guard let currentJob = currentJob else { return }
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        let dict : [String : Any?] = ["job" : jobNameText,
                                      "account_id" : accountID,
                                      "display_num": tfIndex.text]
        RealmServices.shared.update(currentJob, with: dict)

        if isNewObject {
            APIRequest.onAddNewJob(accID: currentJob.account_id, job: currentJob) { (status) in
                if status == 1 {
                    self.onUpdateRealm(currentJob: currentJob)
                    self.onReloadData?()
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                SVProgressHUD.dismiss()
            }
        } else {
            APIRequest.onUpdateJob(job: currentJob, completion: { (success) in
                if success {
                    self.onUpdateRealm(currentJob: currentJob)
                    self.onReloadData?()
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                SVProgressHUD.dismiss()
            })
        }
    }
    private func onUpdateRealm(currentJob:JobData) {
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        setValueToCurrentObject(accountID,                      forKey:"account_id")
        setValueToCurrentObject(tfJobName.text,        forKey:"job")
        setValueToCurrentObject(tfIndex.text,          forKey: "display_num")
        currentJob.updateUpdated()
        onEditingEnded?(currentJob)
        
        isEdited = false
        view.endEditing(true)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentJob = currentJob else { return }
        RealmServices.shared.saveObjects(objs:currentJob) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentJob, with:[key:value])
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
        let alert = UIAlertController(title:nil, message:"スタッフ『\(currentJob?.job ?? "")』を削除します。この操作は取り消せません。", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentJob))
        alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
        present(alert, animated:true, completion:nil)
    }
    private func deleteCurrentJob(alert:UIAlertAction) {
        guard let deleteJob = currentJob else { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        //API handler
        APIRequest.onDeleteJob(jobID: deleteJob.id, completion: { (success) in
            if success {
                RealmServices.shared.delete(deleteJob)
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
