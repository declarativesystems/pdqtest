# Emoji

Emoji are used within PDQTest to indicate progress and overall status at the request of PDQTest user.  Emoji are great because by visually scanning for a distinctive symbol, the user is able to understand the overall test status without having to scan through all of the debug messages.

## What do the emoji mean?

### Progress
`😬` Test passed

`💣` Test failed

# Overall status
`😎` All tests passed

`💩` One or more tests failed


## Disabling emoji
In some cases it may be desirable to diable the emoji, in this case use the argument:

```
--disable-emoji
```

When running PDQTest
