platform :ios, '12.0'
inhibit_all_warnings!

def app_pods

# Architecture
pod 'ReactorKit'

# Reactive
pod 'RxSwift'
pod 'RxCocoa'
pod 'RxDataSources'
pod 'RxOptional'

# UI
pod 'SnapKit'

end

target 'GitTime' do
  use_frameworks!

app_pods

  target 'GitTimeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GitTimeUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
