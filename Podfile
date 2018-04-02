source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
workspace 'POSLens'

abstract_target 'All' do
    pod 'ReactiveObjC', :git => 'https://github.com/pavelosipov/ReactiveObjC.git', :inhibit_warnings => true
    target 'POSLens'
    target 'POSLensTests' do
        pod 'POSLens', :path => '.'
        pod 'POSAllocationTracker'
    end
end
