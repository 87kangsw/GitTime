platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!

def app_pods
  
  # UI
  pod 'SnapKit'
  pod 'Toaster', :git => 'https://github.com/devxoul/Toaster.git', :branch => 'master'
  pod 'PanModal'
  
  # Keychain
  pod 'KeychainAccess'
  
  # DB
  pod 'RealmSwift'
  
  # Logger
  pod 'SwiftyBeaver'
  
  # Network
  pod 'Moya/RxSwift'
  
  # Image Cache
  pod 'Kingfisher'
  
  # etc
  pod 'SwiftLint'
  pod 'AcknowList'
  pod 'Bagel'
  pod 'Kanna'
  pod 'Then'
  pod 'URLNavigator'
  pod 'ReusableKit'
  
  # DI
  pod 'Pure'
end

def firebase_pods
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
    pod 'RxTest'
    pod 'RxBlocking'
    pod 'Stubber'
    pod 'Immutable'
end

target 'GitTime' do
  
  app_pods
  firebase_pods
  
  target 'GitTimeTests' do
    inherit! :search_paths
    testing_pods
  end
  
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
end
