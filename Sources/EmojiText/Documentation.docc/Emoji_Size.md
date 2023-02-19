# Emoji Size

While ``EmojiText`` tries to determine the size of the emoji based on the current font and dynamic type size this only works with the system text styles, this is due to limitations of `SwiftUI.Font`

## Overview

In case you use a custom font or want to override the calculation of the emoji size for some other reason you can provide a emoji size with

```swift
.emojiSize(/* size in px */)
```
