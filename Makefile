project:
	xcodegen generate --spec project.yml --use-cache
	pod install

clean:
	rm -rf ./DrivedData/
	pod deintegrate
