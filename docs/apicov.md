# API Coverage
This is all API that's currently implemented in CX16 MOS. Stuff that's not mentioned is likely to be unimplemented. Note that any reliance on Acorn MOS internals (such as variables at `&80`-`&FC` and `&0251`-`&03FF` ranges or internal code at `&F800`-`&FF00`) will never be supported, because it's not public API.

## OSWORD
- `&00` &ndash; Currently, a simple Wrapper for KERNAL `BASIN` instead of a custom implementation imitating BBC Micro version. This allows the user to perform screen editing like on C64 or CX16 BASIC. But sadly, it also restricts the length of a text line that can be inputed at once to 80 chars (BBC Micro allows for much more characters per input and BBC BASIC by design encourages long lines of code in certain situations)

## OSBYTE
- `&00` &ndash; Identifies the host device as "CBM compatible"
- `&7E` &ndash; Does... something I guess.
- `&81` &ndash; Identifies the device as Commander X16. other functionality of this OSBYTE are not implemented
- `&83` &ndash; MEMBOT
- `&84` &ndash; MEMTOP

## VDU codes
Unsupported VDU codes will generate a visual output that informs about an unsupported VDU code being sent. for example `VDU 1` will generate `@A` output, `VDU 2` `@B` etc.
|     | `+0` | `+1` | `+2` | `+3` | `+4` | `+5` | `+6` | `+7` |
|-|-|-|-|-|-|-|-|-|
|`&00`|✅|❌|❌    |❌|❌|❌    |❌|✅|
|`&08`|❌|✅|🟡[^1]|❌|✅|🟡[^1]|❌|❌|
|`&10`|❌|✅|❌    |❌|✅|❌    |❌|❌|
|`&18`|❌|❌|❌    |✅|❌|❌    |✅|❌|

- ✅ &ndash; implemented
- ❌ &ndash; unimplemented
- 🟡 &ndash; partially implemented

[^1]: `VDU 10, 13` and `VDU 13, 10` will generate a new line as expected. `VDU 10` on its own however won't do anything, while `VDU 13` on its own will act like in OSASCI call.

## OSFILE
- `&FF` &ndash; Loads a file to an address specified by the caller. Execution address field is ignored completely and is treated as if it was set to 0. The file is expected to be a regular file ***without*** a CBM address header.

## Vectors
Currently, only `BRKV` and `WRCHV` are implemented, because BBC BASIC requires them to exist. Other ones may get implemented if they seem apropriate for this project. Some vectors, for example `USERV`, openly encourage relying on internal variables of Acorn MOS and therefore it's unsuited for CX16 MOS.