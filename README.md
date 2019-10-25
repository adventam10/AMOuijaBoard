# AMOuijaBoard

![Pod Platform](https://img.shields.io/cocoapods/p/AMOuijaBoard.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/AMOuijaBoard.svg?style=flat)
[![Pod Version](https://img.shields.io/cocoapods/v/AMOuijaBoard.svg?style=flat)](http://cocoapods.org/pods/AMOuijaBoard)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

`AMOuijaBoard ` is a view can select text.

## Demo

![board](https://user-images.githubusercontent.com/34936885/67257594-babb0a00-f4c7-11e9-98ba-32f18c7b2d9c.gif)

## Usage

Create boardView. (min width: 300, max width: 600, min height: 212.16, max height: 424.32)

Aspect ratio is 1 : 1.414.

```swift
let boardView = AMOuijaBoardView(frame: view.bounds)

// customize here

boardView.delegate = self
view.addSubview(boardView)
```

Conform to the protocol in the class implementation.

```swift
func ouijaBoardView(_ ouijaBoardView: AMOuijaBoardView, didSelectKey key: AMOuijaBoardView.Key) {
  switch key {
  case .goodbye:
    // selected Goodbye
    break
  case .no:
    // selected No
    break  
  case .yes:
    // selected Yes
    break
  case .alphabet(let text):
    // selected alphabet
    // use selected text here
    break
  case .number(let text):
    // selected number
    // use selected text here
    break
  } 
}
```

### Customization
`AMOuijaBoard` can be customized via the following properties.

```swift
public var font: UIFont = UIFont(name: "AcademyEngravedLetPlain", size: 15) ?? .systemFont(ofSize: 15)
public var textColor: UIColor = .init(red: 45/255, green: 49/255, blue: 56/255, alpha: 1.0)
public var markColor: UIColor = .init(red: 45/255, green: 49/255, blue: 56/255, alpha: 1.0)
public var borderLineColor: UIColor = .init(red: 45/255, green: 49/255, blue: 56/255, alpha: 1.0)
public var starCircleColor: UIColor = .init(red: 61/255, green: 117/255, blue: 93/255, alpha: 1.0)
public var boardStartColor: UIColor = .init(red: 247/255, green: 230/255, blue: 185/255, alpha: 1.0)
public var boardEndColor: UIColor = .init(red: 229/255, green: 196/255, blue: 141/255, alpha: 1.0)
public var cursorColor: UIColor = .init(red: 196/255, green: 194/255, blue: 195/255, alpha: 1.0)
```

## Installation

### CocoaPods

Add this to your Podfile.

```ogdl
pod 'AMOuijaBoard'
```

### Carthage

Add this to your Cartfile.

```ogdl
github "adventam10/AMOuijaBoard"
```

## License

MIT

