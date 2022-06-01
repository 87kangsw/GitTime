project:
	xcodegen generate --spec project.yml
	pod install

clean:
	rm -rf ./DrivedData/
	pod deintegrate

upload-firebase:
	fastlane ios distribute_dev firebase_upload:true groups:iOS slack_notify:true

appstore:
	fastlane ios release

get-certs:
	fastlane ios certificate --verbose