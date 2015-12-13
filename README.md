Requires emu8086 (FASM-based compiler with some included macros)

- Compile goatse.asm
- Write resulting boot file to sector 0 of a floppy disk image
- Copy ASCII goatse (helpfully included) at 0x200 of the floppy disk image
- Load in VMWare and goatse your friends

goatse.dsk has it all preloaded on a floppy image. I think you need to disable the magic sector check in VMWare.