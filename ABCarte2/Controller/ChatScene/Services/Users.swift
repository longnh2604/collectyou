//
//  Users.swift
//  Chat
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import Foundation
import ConnectyCube
import SwiftDate

let DefaultUserPassword = "abcd1234"

class Users: NSObject {
    
    var sortedData: SortedDataProvider<User>!

    override init() {
        super.init()
        // Default sort view
        sortedData = SortedDataProvider(sorting: { (u1, u2) -> ComparisonResult in
            if u1.fullName == nil || u1.fullName == "" {
                u1.fullName = "Error"
            }
            if u2.fullName == nil || u2.fullName == "" {
                u2.fullName = "Error"
            }
        
            return u1.fullName!.compare(u2.fullName!)
        })
        Cache.users.register(sortedDataProvider: sortedData)
    }
    
    private let errorHandler : (_ error: Error) -> Void = {
        
        if let reason = ($0 as NSError).userInfo[NSLocalizedFailureReasonErrorKey] as! [AnyHashable : Any]? {
            if let errors = reason["errors"] as? [AnyHashable : Any] {
                if let key = errors.keys.first, let value = (errors[key] as! [String]).first {
                    SVProgressHUD.showError(withStatus: "\(key): " + value)
                    return
                }
            }
        }
        SVProgressHUD.showError(withStatus: $0.localizedDescription)
    }
    
    /// Signup user / Login / Upload user image / Update user.
    ///
    /// - Parameters:
    ///   - user: user: User instance to signup
    ///   - imageData: PNG image date (user image)
    ///   - progress:  Upload progress handler
    ///   - completion: Completion handler
    public func signUp(withUser user: User, imageData: Data, progress: @escaping (Float) -> Void, completion: @escaping () -> Void) {
        //Signup user
        self.signUp(withUser: user, completion: {
            //Login (need for upload file & update current user)
            self.login(withUser: user, force: true){
                //Upload png file data
                Request.uploadFile(with: imageData, fileName: "avatar.png", contentType: "image/png", isPublic: true, progressBlock:{ (uploadProgress) in
                    progress(uploadProgress)
                }, successBlock: { (blob) in
                    let updateParameters = UpdateUserParameters()
                    updateParameters.customData = blob.publicUrl()
                    //Update curent user (add image public url)
                    Request.updateCurrentUser(updateParameters, successBlock: { (user) in
                        //Update user in cache
                        Cache.users.insert(user)
                        completion()
                    }, errorBlock: self.errorHandler)
                }, errorBlock: self.errorHandler)
            }
        })
    }
    
    ///  User sign up
    ///
    /// - Parameters:
    ///   - user: User instance to signup.
    ///   - completion: Completion handler.
    public func signUp(withUser user: User, completion: @escaping () -> Void) {
        user.password = DefaultUserPassword
        Request.signUp(user, successBlock: { (user) in
            Cache.users.insert(user)
            completion()
        }, errorBlock: self.errorHandler)
    }
    
    /// Login with User Instance
    ///
    /// - Parameters:
    ///   - user: User to login
    ///   - completion: Completion handler.
    public func login(withUser user: User, force: Bool = false, completion: @escaping () -> Void) {
        user.password = DefaultUserPassword
        if Session.current.currentUserID != 0, !Session.current.tokenHasExpired, !force {
            completion()
        }
        else {
            Request.logIn(withUserLogin: user.login!, password: user.password!, successBlock: { (user) in
                completion()
            }, errorBlock: self.errorHandler)
        }
    }
    
    /// Get users updates
    public func getUpdates() {
        let paginator = Paginator.limit(100, skip: 0)
        //Filtered by update at
        var extRequest : [String: Any] = [:]
        if let date = Profile.lastUsersFetchDate {
            extRequest["filter[]"] = "date updated_at gt " + date.toISO()
        }
        Request.users(withExtendedRequest: extRequest, paginator: paginator, successBlock: { (paginator, users) in
            Profile.lastUsersFetchDate = Date()
            Cache.users.insert(users)
        }, errorBlock: self.errorHandler)
    }
}
