# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

abstract_target 'muster' do

  pod 'Amplify'
  pod 'AmplifyPlugins/AWSCognitoAuthPlugin'
  pod 'AmplifyPlugins/AWSAPIPlugin'
  pod 'AmplifyPlugins/AWSDataStorePlugin'


  target 'muster-point-patrol' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!

  end

  target 'muster-point-client' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!

    # Pods for muster-point-client
    pod 'AWSCore'
    pod 'AWSLocation' 
    pod 'AWSMobileClient'
  end

end