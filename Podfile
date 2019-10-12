platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

def app_pods

# Architecture
pod 'ReactorKit', '2.0.1'

# Coordinator
# pod 'RxFlow', '2.4.0'

# Reactive
pod 'RxSwift', '5.0.0'
pod 'RxCocoa', '5.0.0'
pod 'RxDataSources', '4.0.1'
pod 'RxOptional', '4.0.0'
pod 'RxKeyboard'

# UI
pod 'SnapKit'
pod 'Toaster'

# Keychain
pod 'KeychainAccess'

# DB
pod 'RealmSwift'

# Logger
pod 'SwiftyBeaver'

# Network
pod 'Moya/RxSwift', '14.0.0-alpha.2'
pod 'Kingfisher', '~> 5.0'

# etc
pod 'Firebase/Core'
pod 'Firebase/RemoteConfig'
pod 'Fabric'
pod 'Crashlytics'
pod 'SwiftLint'
pod 'AcknowList'


end

target 'GitTime' do
  
  app_pods
  
  target 'GitTimeTests' do
    inherit! :search_paths
#    app_pods
  end
  
  target 'GitTimeUITests' do
    inherit! :search_paths
# app_pods
  end
end


