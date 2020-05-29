//
//  ConnectyCube+Requests.swift
//  ABCarte2
//
//  Created by Long on 2019/07/04.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation
import ConnectyCube
import Alamofire
import CommonCrypto

typealias UIntCompletion = (_ success: Bool, _ Int: UInt) -> Void
typealias UserCompletion = (_ success: Bool, _ user: User) -> Void
typealias UserStatusCompletion = (_ status: Int, _ user: User) -> Void
typealias UserArrCompletion = (_ success: Bool, _ user: [User]) -> Void
typealias ChatDialogCompletion = (_ success: Bool, _ dialog: ChatDialog) -> Void
typealias ChatDialogArrCompletion = (_ success: Bool, _ dialogs: [ChatDialog]) -> Void

class ConnectyCubeRequest: NSObject {
    
    //*****************************************************************
    // MARK: - Authentication
    //*****************************************************************
    
    //Login (upgrade session token)
    static func onLogin(user:String,pass:String,completion: @escaping UserStatusCompletion) {
        Request.logIn(withUserLogin: user, password: pass, successBlock: { (user) in
            Cache.users.insert(user)
            print("user info = \(user)")
            completion(1,user)
        }) { (error) in
            if error._code == -1009 || error._code == -1005 || error._code == -1001 {
                completion(3,User())
            } else {
                completion(2,User())
            }
        }
    }
    
    //Logout (downgrade session token)
    static func onLogout(completion:@escaping(Bool) -> ()) {
        Request.logOut(successBlock: {
            completion(true)
        }) { (error) in
            print("error = \(error)")
            completion(false)
        }
    }
    
    //*****************************************************************
    // MARK: - User
    //*****************************************************************
    
    //Create User
    static func onCreateUser(login:String,pass:String,email:String,fullName:String,tags:[String],completion: @escaping UserCompletion) {

        let user = User()
        user.login = login
        user.password = pass
        user.email = email
        user.fullName = fullName
        user.customData = pass
        
        Request.signUp(user, successBlock: { (user) in
            completion(true,user)
        }) { (error) in
            completion(false,user)
        }
    }
    
    //Retrieve User by LoginName
    static func onRetrieveUser(user:String,completion: @escaping UserCompletion) {
        Request.user(withLogin: user, successBlock: { (user) in
            Cache.users.insert(user)
            completion(true,user)
        }) { (error) in
            completion(false,User())
        }
    }
    
    //Retrieve Users by LoginName
    static func onRetrieveUsers(loginIDs:[String],completion:@escaping(Bool) -> ()) {
        let paginator = Paginator.limit(100, skip: 0)
        Request.users(withLogins: loginIDs, paginator: paginator, successBlock: { (paginator, users) in
            Cache.users.insert(users)
            completion(true)
        }) { (error) in
            print(error)
            completion(false)
        }
    }
    
    //Retrieve User by Tags
    static func onRetrieveUserByTags(tag:String,completion: @escaping UserArrCompletion) {
        let paginator = Paginator.limit(100, skip: 0)
        let tagSearch = "S\(tag)"
        Request.users(withTags: [tagSearch], paginator: paginator, successBlock: { (paginator, users) in
            completion(true,users)
        }) { (error) in
            print(error)
            completion(false,[User()])
        }
    }
    
    //Retrieve User by Tags
    static func onRetrieveUserByID(id:NSNumber,completion: @escaping UserArrCompletion) {
        let paginator = Paginator.limit(100, skip: 0)
        Request.users(withIDs: [id], paginator: paginator, successBlock: { (paginator, users) in
            completion(true,users)
        }) { (error) in
            print(error)
            completion(false,[User()])
        }
    }
    
    //Update User Avatar
    static func onUpdateUserAvatar(avatar: UIImage,completion:@escaping(Bool) -> ()) {
        
        SVProgressHUD.showProgress(0)
        let data = avatar.pngData()
        Request.uploadFile(with: data!, fileName: "Avatar", contentType: "image/png", isPublic: true, progressBlock: { (progress) in
            SVProgressHUD.showProgress(progress)
        }, successBlock: { (blob) in
            
            let parameters = UpdateUserParameters()
            parameters.avatar = blob.publicUrl()
    
            Request.updateCurrentUser(parameters, successBlock: { (user) in
                Profile.currentProfile = user
                SVProgressHUD.dismiss()
                completion(true)
            }, errorBlock: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                completion(false)
            })
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            completion(false)
        }
    }
    
    //*****************************************************************
    // MARK: - Messaging
    //*****************************************************************
    
    //get all dialogs
    static func onGetAllDialogs(completion: @escaping ChatDialogArrCompletion) {
        let paginator = Paginator.limit(100, skip: 0)
        let extRequest : [String: String] = ["type" : "3",
                                             "dialogDescription[in]":"227905,193066"]
        var dialogsArr : [ChatDialog] = []
        
        func Recurcive<T>(_ R: (@escaping (@escaping (T) -> Void) -> (T) -> Void)) -> (T) -> Void {
            return { x in R(Recurcive(R))(x) }
        }

        Recurcive { R in
            { paginator in
                Request.dialogs(with: paginator, extendedRequest: extRequest, successBlock: { (dialogs, users, paginator) in
                    dialogsArr.append(contentsOf: dialogs)
                    if dialogs.count < paginator.limit {
                        completion(true, dialogsArr)
                        return
                    }
                    paginator.skip += UInt(dialogs.count)
                    R(paginator)
                }, errorBlock: { (error) in
                    print("error = \(error)")
                    completion(false, dialogsArr)
                })
            }
            } (Paginator.limit(100, skip: 0))
    }
    
    //connect to Chat
    static func onConnectToChat(userID:UInt,pass: String,completion:@escaping(Bool) -> ()) {
        Chat.instance.connect(withUserID: userID, password: pass) { (error) in
            if let error = error {
                switch error._code {
                case -1000:
                    completion(true)
                default:
                    completion(false)
                }
            } else {
                completion(true)
            }
        }
    }
    
    //disconnect
    static func onDisconnectChat(completion:@escaping(Bool) -> ()) {
        Chat.instance.disconnect { (error) in
            if let error = error {
                switch error._code {
                case -1003:
                    completion(true)
                default:
                    completion(false)
                }
            } else {
                completion(true)
            }
        }
    }
    
    //open chat 1-1
    static func onOpen1vs1Chat(with cusID:NSNumber,imgDescription:String,completion: @escaping ChatDialogCompletion) {
        let dialog = ChatDialog(dialogID: nil, type: .private)
        dialog.occupantIDs = [cusID]  // an ID of opponent
        dialog.photo = imgDescription
        
        Request.createDialog(dialog, successBlock: { (dialog) in
            completion(true,dialog)
        }) { (error) in
            completion(false,dialog)
        }
    }
    
    static func onUpdateDialog1vs1(dialogID:String,cusID:String,completion:@escaping(Bool) -> ()) {
        let parameters = UpdateChatDialogParameters()
        parameters.name = cusID

        Request.updateDialog(withID: dialogID, update: parameters, successBlock: { (updatedDialog) in
            completion(true)
        }) { (error) in
            completion(false)
        }
    }
    
    static func onGetChatHistory(with dialogID:String,completion:@escaping(Bool) -> ()) {
        //get current date
        let currDate = Date()
        let timeInterval = Int(currDate.timeIntervalSince1970)
        
        Request.messages(withDialogID: dialogID,
                          extendedRequest: ["date_sent[gt]":"\(timeInterval)"],
                          paginator: Paginator.limit(20, skip: 0),
                          successBlock: { (messages, paginator) in
                            print("mess = \(messages) and pag = \(paginator)")
                            completion(true)
        }) { (error) in
            print("error = \(error)")
            completion(false)
        }
    }
    
    //send message
    static func onSendMessage(msg:String,dialog:ChatDialog,completion:@escaping(Bool) -> ()) {
        
        let message = ChatMessage()
        message.text = msg
        
        dialog.send(message) { (error) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    //request unread message
    static func onRequestUnreadMessage(ids:[String],completion:@escaping(Bool) -> ()) {
      
        Request.totalUnreadMessageCountForDialogs(withIDs: Set(ids),
                                                  successBlock: { (count, dialogs) in
            print("dialogs =\(dialogs)")
        }) { (error) in
            print(error)
        }
    }
}
