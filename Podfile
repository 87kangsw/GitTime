platform :ios, '12.0'
inhibit_all_warnings!

def app_pods

# Architecture
pod 'ReactorKit'

# Coordinator
pod 'RxFlow'

# Reactive
pod 'RxSwift'
pod 'RxCocoa'
pod 'RxDataSources'
pod 'RxOptional'
pod 'RxKeyboard'

# UI
pod 'SnapKit'
pod 'Toaster'

# Keychain
pod 'KeychainAccess'

# Logger
pod 'SwiftyBeaver'

# Network
pod 'Moya/RxSwift', '~> 13.0'
pod 'Kingfisher', '~> 5.0'

# etc
pod 'Firebase/Core'
pod 'Fabric', '~> 1.9.0'
pod 'Crashlytics', '~> 3.12.0'
pod 'SwiftLint'
pod 'AcknowList'


end

target 'GitTime' do
  use_frameworks!

  app_pods
end

target 'GitTimeTests' do
  inherit! :search_paths
  app_pods
end

target 'GitTimeUITests' do
  inherit! :search_paths
  app_pods
end
