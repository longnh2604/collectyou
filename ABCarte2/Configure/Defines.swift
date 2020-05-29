//
//  Defines.swift
//  ABCarte2
//
//  Created by Long on 2018/05/15.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation

//*****************************************************************
// MARK: - Staff Permission
//*****************************************************************

enum StaffPermission: Int {
    case customer = 1
    case karte = 2
    case brochure = 3
    case contract = 4
}

//*****************************************************************
// MARK: - Popup Style
//*****************************************************************

enum PopUpType:Int{
    case AddNew = 1
    case Edit = 2
    case Review = 3
}

//*****************************************************************
// MARK: - Document Style
//*****************************************************************

enum DocType:Int{
    case Consent
    case Counselling
    case Handwritting
    case Outline
}

//*****************************************************************
// MARK: - Document Style
//*****************************************************************

enum ImageResolution:Int{
    case low = 0
    case medium = 1
    case high = 2
}

//*****************************************************************
// MARK: - Functions Type
//*****************************************************************

enum AppFunctions:Int {
    case kMultiLanguage = 1
    case kMultiTheme = 2
    case kVideo = 3
    case kSecretMemo = 4
    case kCompareTranmission = 5
    case kMorphing = 6
    case kShootingTranmission = 7
    case kTextSticker = 8
    case kDrawingPrinter = 9
    case kComparePrinter = 10
//    case kCounselling = 11
//    case kConsent = 12
    case kJBS = 13
    case kFullStampSticker = 15
    case kMosaic = 16
    case kPenSize = 17
    case kCalendar = 18
    case kPhotoResolution = 19
    case kSilhouette = 20
    case kEyeDrop = 21
    case kOpacity = 22
//    case kCarteDocs = 23
//    case kAdditionalDoc = 24
    case kCustomerFlag = 25
    case kShop = 26
    case kPicLimit = 27
    case kPhotoExport = 28
    case kMessenger = 29
    case kContract = 30
    case kDocumentNo = 31
    case kCarteTime = 32
    case kFreeMemoSearch = 33
    case kStampMemoSearch = 34
    case kUpDownDocCarte = 35
    case kColorfulPenDoc = 36
    case kMessageEdit = 37
    case kCustomerSwitch = 38
    case kDB = 39
    case kStaffManagement = 40
    case kBedManagement = 41
    case kCarteEdit = 42
    case kSettlement = 43
    case kPaymentManagement = 44
    case kMessageInfo = 45
    case kMessageLimitCharacter = 46
    case kCustomerSignDrawingAddition = 47
    case kJobManagement = 48
}
