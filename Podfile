# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# Update this to point to your local amplify-ios repository

target 'ReceiptModel' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReceiptModel
  # Amplify (explicit dependencies required when using pods with local path)
  pod 'Amplify'  

  # Amplify Plugins
  pod 'AmplifyPlugins/AWSCognitoAuthPlugin'
  pod 'AmplifyPlugins/AWSAPIPlugin'
  pod 'AmplifyPlugins/AWSDataStorePlugin'

  target 'ReceiptModelTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
