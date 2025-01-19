const
 {$ifdef windows}
 SDLLibName = 'SDL.dll';
 {$endif}
 {$ifdef linux}
 SDLLibName = 'libSDL2.so';
 {$endif}

type
 UInt32 = Cardinal;  
 PUInt8 = pbyte;
 UInt8 = byte;
 UInt16 = word;
