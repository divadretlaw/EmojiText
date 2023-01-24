# EmojiText

Render Custom Emoji in `Text`. Supports local and remote emojis. Remote emojis are loadad and cached using [Nuke](https://github.com/kean/Nuke)

## Usage

Remote emoji

```swift
EmojiText(verbatim: "Hello World :my_emoji:",
          emojis: [RemoteEmoji(shortcode: "my_emoji", url: /* URL to emoji */)])
```

Local emoji

```swift
EmojiText(verbatim: "Hello World :my_emoji:",
          emojis: [LocalEmoji(shortcode: "my_emoji", image: /* some UIImage */)])
```

### Markdown

Also supports Markdown

```swift
EmojiText(markdown: "**Hello** *World* :my_emoji:",
          emojis: [RemoteEmoji(shortcode: "my_emoji", url: /* URL to emoji */)])
```

## Configuration

Remote emojis are replaced by a placeholder image. Default is the SF Symbol `square.dashed` but you can provide a placeholder image with

```swift
.environment(\.placeholderEmoji, /* some UIImage */)
```

Remote emojis use `ImagePipeline.shared` from [Nuke](https://github.com/kean/Nuke) but you can provide a custom pipline with

```swift
.environment(\.imagePipeline, ImagePipeline())
```

## License

See [LICENSE](LICENSE)
