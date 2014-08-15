Dump binary data to console from file or disk.

Usage:
HexDump InputFilename Filepos Numbytes
-InputFilename can be a filename or volume/disk path
-Filepos and numbytes can be in decimal or hex
-Numbytes of 0 will resolve to filesize unless InputFilename is of type volume or disk

Examples:
HexDump D:\diskimage.img 0x2800 0x200
HexDump C: 0x0 0x200
HexDump PhysicalDrive1 0x0 0x200
