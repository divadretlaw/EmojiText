# EmojiText

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdivadretlaw%2FEmojiText%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/divadretlaw/EmojiText)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdivadretlaw%2FEmojiText%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/divadretlaw/EmojiText)


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

### Animated Emoji

> [!WARNING]
> This feature is in beta and therefore is opt-in only. Performance may vary.

Currently only UIKit platforms support animated emoji.

Enable animation by setting adding the `.animated()` modifier to `EmojiText`.

```swift
EmojiText(verbatim: "GIF :my_gif:",
          emojis: [RemoteEmoji(shortcode: "my_gif", url: /* URL to gif */)])
    .animated()
```

Supported formats:

- APNG
- GIF
- WebP

> [!INFO]
> The animation will automatically pause when using low-power mode. To always play animations, even in low-power mode set the animation mode to `AnimatedEmojiMode.always`
> 
> ```swift
> EmojiText(verbatim: "GIF :my_gif:",
>           emojis: [RemoteEmoji(shortcode: "my_gif", url:  ? URL to gif */)])
>   .animated()
>   .environment(\.emojiAnimatedMode, .always)
> ```

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
