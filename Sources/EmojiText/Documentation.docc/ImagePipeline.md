# Nuke

``EmojiText`` resolves remote emojis using `Nuke` and defaults to `ImagePipeline.shared` for the `ImagePipeline`

## Overview

In order to use a custom `ImagePipeline` you can provide a custom pipeline with

```swift
.environment(\.emojiText.imagePipeline, ImagePipeline())
```

For further information, please refer to the official documenation: [Nuke](https://kean-docs.github.io/nuke/documentation/nuke/getting-started/)
