project:
	xcodegen generate --spec project.yml
	pod install

clean:
	rm -rf ./DrivedData/
	pod deintegrate

dev-upload:
	fastlane ios develop firebase_upload:true groups:iOS slack_notify:true