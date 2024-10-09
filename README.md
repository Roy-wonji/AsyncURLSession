
# AsyncURLSession

![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
[![License](https://img.shields.io/github/license/pelagornis/PLCommand)](https://github.com/pelagornis/PLCommand/blob/main/LICENSE)
![Platform](https://img.shields.io/badge/platforms-macOS%2010.5-red)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FMonsteel%2FAsyncMoya&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
         

💁🏻‍♂️ iOS13+ 를 지원합니다.<br>
💁🏻‍♂️ URLSession을 기반으로 하여 구현되었습니다.<br>
💁🏻‍♂️ URLSession의 다양한 옵션을 지원합니다.<br>
                  
## 장점
✅ AsyncURLSession 사용하면, 네트워킹 코드를 좀더 간결하게 사용 할수 있어요!

## 기반
이 프로젝트는 [URLSession](https://developer.apple.com/documentation/foundation/urlsession)을 기반으로 구현되었습니다.<br>
보다 자세한 내용은 해당 라이브러리의 문서를 참고해 주세요


## Swift Package Manager(SPM) 을 통해 사용할 수 있어요
```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/Roy-wonji/AsyncURLSession.git", from: "1.0.0")
    ],
    ...
)
```

```swift
import AsyncURLSession
```
                     
###  requestAsync
#### async/await만 사용하게 구현

```swift
import AsyncURLSession

let provider = AsyncProvider<GitHub>()

 func getDate() async throws -> CurrentDate? {
    return try await provider.requestAsyncAwait(.getDate, decodeTo: CurrentDate.self)
}
```
