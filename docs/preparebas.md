# Preparing BBC BASIC language ROM

Generally, while CX16 MOS was mostly made with BBC BASIC IV in mind, you can insert any kind of language ROM as long as it's designed to fit into `&B800`-`&F7FF` space, has its entry point at `&B800`, doesn't use `&00` and `&01` regs as RAM, doesn't rely on internals of Acorn's original MOS and can at least to some extent work with what's currently implemented in this implementation of MOS. Still, this MOS was primarily made with BBC BASIC IV in mind, so we will focus on how to prepare the ROM for inclusion in cartridge.

## Downloading and preparing BBC BASIC IV

1. From [this mdfs.net site](https://mdfs.net/Software/BBCBasic/BBC/), download a rom called "HiBasic 4.01".
2. Using a hex editor or other tool, split the rom into two parts: 2KB part (`&000`-`&7FF` offset range) and 14KB (`&0800`-`&4000` offset range). First part should be called `basic4lo.bin` while the larger one `basic4hi.bin`.
3. Checksum the `basic4hi.bin` file. This is the SHA-256 sum you should get:
    ```
    13d3f6bf0b7467e1c3556e0d592c4cf3606d5cb20dbdc24b4925f9be7df7f644
    ```
4. If the checksum is correct, you will be able to apply [`basic4hi.ips`](/basic4hi.ips) patch to the ROM file using a program that supports IPS format. This patch removes the deppendence on `&00` and `&01` addresses from BASIC. the resulting SHA-256 code should be:
    ```
    df69ac4597bf34d10529f07f5316d15a22f21055e318b68621cc82bc8d79ed23
    ```
5. Inside the repository, create `roms` folder and place the ROM files inside it. Alternatively, you can place these ROM files in `src` directory alongside MOS source code.
