@echo off
ROBOCOPY "%appdata%\LOVE\Marin0SE\mappacks" "marin0SE\mappacks" /DCOPY:DA /FFT /Z /XA:SH /IT /R:0 /TEE /XJD /E /MOVE
exit