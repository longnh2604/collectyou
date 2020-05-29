# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ABCarte2' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Issue with IBDesignable: https://github.com/CocoaPods/CocoaPods/issues/7606#issuecomment-381279098
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end

  # Pods for ABCarte2
pod 'IQKeyboardManagerSwift'
pod 'BarcodeScanner', '4.1.3'
pod 'RealmSwift'
pod 'Alamofire'
pod 'AlamofireImage'
pod 'SwiftyJSON'
pod 'SDWebImage'
pod 'lottie-ios'
pod 'SnapKit'
pod 'TransitionButton', :git => 'https://github.com/AladinWay/TransitionButton.git'
pod 'Charts'
pod 'ReachabilitySwift'
pod 'Pickle'
pod 'CITreeView'
pod 'UXMPDFKit'
pod 'ConnectyCube'
pod 'SlackTextViewController', '~> 1.9.6'
pod 'YapDatabase', '~> 3.1.2'
pod 'PINRemoteImage', '~> 2.1.4'
pod 'LetterAvatarKit', '~> 1.1.7'
pod 'SwiftDate', '~> 5.1.0'
pod 'SwiftMessages', '5.0.1'
pod 'Reusable', '~> 4.0.5'
pod 'Lightbox', '~> 2.1.2'
pod 'MMPlayerView'
pod 'PDFGenerator'
pod 'AMPopTip'
pod 'HueKit'
pod 'Firebase/Core'
pod 'BadgeSwift'
pod 'LGButton'
pod 'EFColorPicker'
end
