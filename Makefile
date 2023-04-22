project:
	xcodegen generate --spec project.yml

clean:
	rm -rf ./DrivedData/

dev-upload:
	fastlane ios develop firebase_upload:true groups:iOS slack_notify:true

appstore:
	fastlane ios release

certificates:
	fastlane ios certificates	