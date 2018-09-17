# Emoji

Emoji are used within PDQTest to indicate progress and overall status at the 
request of PDQTest user.  Emoji are great because by visually scanning for a
distinctive symbol, the user is able to understand the overall test status
without having to scan through all of the debug messages.

On windows, there is very limited support for Unicode in the terminal except in
PowerShell ISE which is not compatible with PDK
[PDK-1168](https://tickets.puppetlabs.com/browse/PDK-1168).

On windows, we fallback to output emoticons instead of Emoji

## What do the emoji mean?

### Progress

| Symbol | Meaning | Platform                                 |
| ---    | ---                             | ---              |
| Progress: Test passed                    | `😬` | `:-)`      |
| Progress: Test failed                    | `💣` | `●~*`      |
| Overall Status: All tests passed         | `😎` | `=D`       |
| Overall Status: One or more tests failed | `💩` | `><(((*>`  |
| Slow operation                           | `🐌` | `(-_-)zzz` |
| Platform issue/limitation                | - | `(-_-)`       |


## Disabling emoji
In some cases it may be desirable to disable the emoji, in this case use the 
argument:

```
--disable-emoji
```

When running PDQTest
