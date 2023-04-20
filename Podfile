platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!

def app_pods
  
  # UI
  pod 'Toaster', :git => 'https://github.com/devxoul/Toaster.git', :branch => 'master'

  # etc
  pod 'SwiftLint'
  pod 'AcknowList'
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
