platform :ios, '10.0'
source 'https://github.com/CocoaPods/Specs.git'

def datalayer
	# database management
    pod 'MagicalRecord', git:'https://github.com/magicalpanda/MagicalRecord.git' ,branch: 'release/3.0'
    pod 'EncryptedCoreData', git: 'https://github.com/project-imas/encrypted-core-data'
end

def networklayer
	# network
	pod 'Alamofire'
	# pod 'SWXMLHash', '~> 4.0.0'
	pod 'XMLDictionary'
end

def uikit
	# well-styled progress hud
	# pod 'MBProgressHUD', '~> 0.9.1'
	# easy autolayout
	pod 'SnapKit'
	# well-styled notifications
	pod 'SwiftMessages'
    # IQKeyboardManager
    pod 'IQKeyboardManagerSwift', '5.0.0'
end

def security
end

def protocols
end

def utilities
	# logging
	pod 'CocoaLumberjack/Swift'
end

def patterns
end

def services
	# statistics
	# pod 'Fabric'
	# pod 'Crashlytics'
	# # rating
end

def infoPlist
end

def targetName
	'SwiftExchanger'
end

def networkLayerFramework
	'NetworkWorm'
end

def databaseLayerFramework
	'DatabaseBeaver'
end

target networkLayerFramework do
	use_frameworks!
	networklayer
end

target databaseLayerFramework do
	use_frameworks!
	datalayer
end

target targetName do
	# inhibit_all_warnings!
	use_frameworks!
	datalayer
	networklayer
	uikit
	security
	protocols
	utilities
	patterns
	services
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
