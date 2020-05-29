//
//  API.swift
//  ABCarte2
//
//  Created by Long on 2018/08/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation

//*****************************************************************
// MARK: - APP URL
//*****************************************************************

let kAPI_URL = "http://collectyou.jp/"
let kAPI_URL_AWS = "https://s3-ap-northeast-1.amazonaws.com/abcarte/"
let kAPI_CHAT_URL = "http://collectyou.jp/chat/"

//*****************************************************************
// MARK: - ACCOUNT & DEVICE
//*****************************************************************

//App
let kAPI_LATEST_VERSION = "v1/fc-apps/get-latest"

//Token
let kAPI_TOKEN = "v1/request-access-token"

//Account
let kAPI_ACC = "v1/fc-accounts"
let kAPI_ACC_ROOT = "v1/fc-accounts/get-root-account"
let kAPI_ACC_GENEALOGY = "v1/fc-accounts/get-genealogy"
let kAPI_ACC_HIERARCHY = "v1/fc-accounts/get-children"
let kAPI_ACC_HIERARCHY_PLUS_ALLIANCE = "v1/fc-accounts/get-hierarchy"
let kAPI_ACC_TRACKING = "v1/fc-accounts/version-tracking"
let kAPI_STORAGE_EXTEND = "v1/fc-mails/account-send"

//*****************************************************************
// MARK: - CUSTOMER
//*****************************************************************

//CUSTOMER
let kAPI_CUS = "v1/fc-customers"

//*****************************************************************
// MARK: - SEARCH
//*****************************************************************

let kAPI_CUS_SEARCH = "v1/fc-customers/search"

let kAPI_CUS_SELECT_DATE_SEARCH = "v1/fc-customers/search-by-carte-select-date"

//*****************************************************************
// MARK: - CARTE
//*****************************************************************

//CARTE
let kAPI_CARTE = "v1/fc-customer-cartes"
let kAPI_CARTE_CLEAR_AVATAR = "v1/fc-customer-cartes/clear-pic"

//*****************************************************************
// MARK: - MEDIA
//*****************************************************************

//MEDIA
let kAPI_MEDIA = "v1/fc-user-media"

//*****************************************************************
// MARK: - MEMO
//*****************************************************************

//MEMO
let kAPI_MEMO = "v1/fc-user-memos"
//STAMP CONFIG
let kAPI_STAMP = "v1/memo-content-cfgs"
//CATEGORY
let kAPI_STAMP_CATEGORY = "v1/fc-categories"
//keyword
let kAPI_KEYWORD = "v1/fc-keywords"
//free memo
let kAPI_FREE_MEMO = "v1/fc-free-memos"
//stamp memo
let kAPI_STAMP_MEMO = "v1/fc-stamp-memos"

//SECRET_MEMO
let kAPI_SECRET_MEMO = "v1/fc-secret-memos"

//*****************************************************************
// MARK: - DOCUMENT
//*****************************************************************

//DOCUMENT
let kAPI_DOCUMENT = "v1/fc-document"

let kAPI_DOCUMENTS = "v1/fc-documents"

//DOCUMENT_PAGE
let kAPI_DOCUMENT_PAGE = "v1/fc-document-pages"

//*****************************************************************
// MARK: - VIDEO
//*****************************************************************

let kAPI_VIDEO = "v1/fc-videos"

//*****************************************************************
// MARK: - CONTRACT
//*****************************************************************

let kAPI_BROCHURE = "v1/fc-brochures"
let kAPI_CONTRACT = "v1/fc-contracts"
let kAPI_COMPANY_STAMP = "v1/fc-c-companies"
let kAPI_CONTRACT_CUSTOMER = "v1/fc-contract-customers"
let kAPI_CONTRACT_COMPANY = "v1/fc-contract-companies"
let kAPI_CONTRACT_SUB_COMPANY = "v1/fc-contract-sub-companies"
let kAPI_COURSE_ORDER = "v1/fc-cour-orders"
let kAPI_GOOD_ORDER = "v1/fc-good-orders"
let kAPI_SETTLEMENT = "v1/fc-settlements"
let kAPI_COMPANY = "v1/fc-c-companies"
let kAPI_STAFF = "v1/fc-mstaff"
let kAPI_BED = "v1/fc-beds"
let kAPI_ADDITION = "v1/fc-cdetail"
let kAPI_JOB = "v1/fc-mjob"
let kAPI_JOBS = "v1/fc-mjobs"

let kAPI_COURSE_CATEGORY = "v1/fc-cour-categories"
let kAPI_COURSE = "v1/fc-cours"

let kAPI_PRODUCT_CATEGORY = "v1/fc-good-categories"
let kAPI_PRODUCT = "v1/fc-goods"

let kAPI_PAYMENT = "v1/fc-payments"
let kAPI_CREDIT = "v1/fc-m-credits"
let kAPI_SHOPPINGCREDIT = "v1/fc-m-shopping-credits"
let kAPI_EMONEY = "v1/fc-m-emoneys"

//*****************************************************************
// MARK: - MESSENGER
//*****************************************************************

let kAPI_MESSENGER = "v1/fc-messenger-categories"
let kAPI_MESSENGER_ITEMS = "v1/fc-messenger-category-items"
