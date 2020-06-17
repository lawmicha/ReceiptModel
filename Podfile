# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# Update this to point to your local amplify-ios repository
$LOCAL_REPO = '~/aws-amplify/amplify-ios'

target 'ReceiptModel' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReceiptModel
  # Amplify (explicit dependencies required when using pods with local path)
  pod 'Amplify', :path => $LOCAL_REPO
  pod 'AmplifyPlugins', :path => $LOCAL_REPO # No need for this when not using local pods
  pod 'AWSPluginsCore', :path => $LOCAL_REPO # No need for this when not using local pods

  # Amplify Plugins
  pod 'AmplifyPlugins/AWSCognitoAuthPlugin', :path => $LOCAL_REPO
  pod 'AmplifyPlugins/AWSAPIPlugin', :path => $LOCAL_REPO
  pod 'AmplifyPlugins/AWSDataStorePlugin', :path => $LOCAL_REPO

  target 'ReceiptModelTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
