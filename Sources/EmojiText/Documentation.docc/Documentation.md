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

## Topics

### Configuration

- <doc:Placeholder>
- <doc:Emoji_Size>
- <doc:ImagePipeline>
