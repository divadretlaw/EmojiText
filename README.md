# EmojiText

![](https://img.shields.io/badge/Swift-5.7-orange?style=flat-square)
![](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey?style=flat-square)

Render Custom Emoji in `Text`. Supports local and remote emojis. Remote emojis are loaded and cached using [Nuke](https://github.com/kean/Nuke)

## Usage

Remote emoji

```swift
EmojiText(verbatim: "Hello :my_emoji:",
          emojis: [RemoteEmoji(shortcode: "my_emoji", url: /* URL to emoji */)])
```

Local emoji

```swift
EmojiText(verbatim: "Hello :my_emoji:",
          emojis: [LocalEmoji(shortcode: "my_emoji", image: /* some UIImage or NSImage */)])
```

SF Symbol

```swift
EmojiText(verbatim: "Hello Moon & Starts :moon.stars:",
          emojis: [SFSymbolEmoji(shortcode: "moon.stars")])
```

### Markdown

Also supports Markdown

```swift
EmojiText(markdown: "**Hello** *World* :my_emoji:",
          emojis: [RemoteEmoji(shortcode: "my_emoji", url: /* URL to emoji */)])
```

## Configuration

Remote emojis are replaced by a placeholder image when loading. Default is the SF Symbol `square.dashed` but you can overide the placeholder image with

```swift
.placeholderEmoji(systemName: /* SF Symbol */)
```

or

```swift
.placeholderEmoji(image: /* some UIImage or NSImage */)
```

Remote emojis use `ImagePipeline.shared` from [Nuke](https://github.com/kean/Nuke) to load them, but you can provide a custom pipeline with

```swift
.environment(\.emojiImagePipeline, ImagePipeline())
```

## License

See [LICENSE](LICENSE)
