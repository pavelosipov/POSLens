source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
workspace 'POSLens'

abstract_target 'All' do
    pod 'ReactiveObjC', :inhibit_warnings => true
    pod 'POSErrorHandling', :git => 'https://github.com/pavelosipov/POSErrorHandling.git'
    target 'POSLens'
    target 'POSLensTests' do
        pod 'POSLens', :path => '.'
        pod 'POSAllocationTracker'
    end
end
