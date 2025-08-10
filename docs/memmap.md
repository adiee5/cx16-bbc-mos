# Memory Map

Here's a flat memory map in a default bank configuration:

| Range | Purpose | Notes |
|-|-|-|
|  `&00`-`&01`  | Memory bank registers |
|  `&02`-`&5F`  | BASIC internals | In BBC BASIC IV, `&52`-`&5F` are technically free |
|  `&60`-`&7f`  | Free | May be occupied by MOS in the future, though that's unlikely |
|  `&80`-`&A8`  | KERNAL internals |
|  `&A9`-`&FC`  | MOS internals |
|  `&FD`-`&FF`  | Error message pointer and "ESCFLG" | Required by BASIC |
|`&0100`-`&01FF`| Stack |
|`&0200`-`&0250`| MOS vector space | KERNAL has a `buf` variable in this place, but it's only used when CX16 BASIC is running. Meanwhile, BBC MOS happens to have its system vectors here. As of now, only two of these vectors are implemented. |
|`&0251`-`&03FF`| KERNAL internals |
|`&0400`-`&07FF`| BASIC internals |
|`&0800`-`&9EFF`| User program space |
|`&9F00`-`&9FFF`| I/O |
|`&A000`-`&B7FF`| MOS variables, code etc. |
|`&B800`-`&F7FF`| BASIC code |
|`&F800`-`&FFFF`| MOS code |

MOS only uses RAM bank #1. It uses 2 16KB ROM banks:

| Bank # | Name | Describtion |
|-|-|-|
| 32 | INITROM  | Contains the initialization code as well as static copies of RAM-allocated code. In the future, it may also contain code of less significant routines |
| 33 | ROM      | The main bank that contains ROM-allocated BASIC code, most important MOS routines and also MOS API entry points. |

The cartridge may be expanded to a 64KB design if the current 32KB of ROM turns out to be not enough. That won't however change the purpose of currently used ROM banks.