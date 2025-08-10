# Acorn MOS for Commander X16

This is an experimental MOS implementation for Commander X16. It's primary purpose is running BBC BASIC on Commander X16.

## Compiling
Since I don't have the rights to distribute BBC BASIC itself, you need to prepare it yourself. [See Instructions how to do that](/docs/preparebas.md).

[`mkca65.bat`](/mkca65.bat) contains the command that will compile the MOS (and include the language ROM) into a raw binary file you can load onto a Cartridge ROM. [`runcx16.bat`](/runcx16.bat) contains commands that will assemble the ROM into a "cartridge file" and run the BBC BASIC in the emulator. `mkcx16cart` is a utility, that's shipped with *x16emulator*, typically under a name `makecart`.

## Contributing
If you'd like to help developing this project, you can join the discussion on [CX16 Discord server](https://discord.gg/nS2PqEC) and let me (@adiee5) know about your interest. Feel free to send me pull requests.

## Acknowledgements
Original MOS and BBC BASIC were made by Acorn Computers Ltd. 

[`JSRFAR`](/src/jsrfar.inc) routine was made by Commander X16 community and is licensed under a BSD license. See the source file for details.

Really great thanks to Jonathan G. Harston and their [mdfs.net](https://mdfs.net/) website for the resources regarding BBC BASIC, MOS and BBC Micro in general.