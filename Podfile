# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

abstract_target 'EscaPAID' do
  # Comment the next line if you're not using
  # Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EscaPAID
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'JSQMessagesViewController'
  pod 'JTAppleCalendar', '~> 7.0'
  pod 'RSKImageCropper'
  pod 'NextResponderTextField'
  pod 'AlamofireImage', '~> 3.3'
  pod 'Hero'
  pod 'ImageSlideshow', '~> 1.6'
  pod 'ImageSlideshow/Alamofire'

  # Pods for Facebook
  pod 'Bolts'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  
  # Stripe
  pod 'Alamofire'
  pod 'Stripe'

  target 'Renaissance Prod'
  target 'Renaissance Dev'
  target 'Tellomee Prod'
  target 'Tellomee Dev'
  
end

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
