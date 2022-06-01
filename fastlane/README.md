fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios distribute_dev

```sh
[bundle exec] fastlane ios distribute_dev
```

Firebase Distribution으로 테스트 배포 진행

### ios certificate

```sh
[bundle exec] fastlane ios certificate
```

인증서 갱신

### ios firebase_upload

```sh
[bundle exec] fastlane ios firebase_upload
```

Firebase distribution을 동작하게 하는 별도의 lane

### ios message_to_slack

```sh
[bundle exec] fastlane ios message_to_slack
```



### ios test_slack

```sh
[bundle exec] fastlane ios test_slack
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
