project:
	xcodegen generate --spec project.yml
	pod install

clean:
	rm -rf ./DrivedData/
	pod deintegrate

dev-upload:
	fastlane ios develop