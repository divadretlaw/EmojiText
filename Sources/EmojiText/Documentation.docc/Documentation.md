# ``EmojiText``

Display text with custom emojis in the format `:emoji:`

## Overview

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

> Warning:
> This feature is in beta and therefore is opt-in only. Performance may vary.

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

> Info:
> The animation will automatically pause when using low-power mode. To always play animations, even in low-power mode set the animation mode to ``AnimatedEmojiMode/always``
> 
> ```swift
> EmojiText(verbatim: "GIF :my_gif:",
>           emojis: [RemoteEmoji(shortcode: "my_gif", url:  ? URL to gif */)])
>   .animated()
>   .environment(\.emojiAnimatedMode, .always)
> ```

## Topics

### Configuration

- <doc:Placeholder>
- <doc:Emoji_Size>
- <doc:ImagePipeline>
