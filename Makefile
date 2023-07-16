help:          
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

project: ## xcodegen으로 프로젝트를 구성합니다
	xcodegen generate --spec project.yml

clean: ## DrivedData을 삭제합니다
	rm -rf ./DrivedData/

dev-upload: ## 개발버전을 firebase로 배포합니다
	fastlane ios develop firebase_upload:true groups:iOS slack_notify:true

appstore: ## 앱스토어에 업로드합니다
	fastlane ios release

certificates: ## 인증서를 갱신합니다
	fastlane ios certificates	

lint: ## 린트를 동작합니다
	fastlane ios lint	