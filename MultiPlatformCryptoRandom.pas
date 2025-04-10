// Tested on Windows, MacOS, Linux, and Android. From what I've read /dev/urandom works on iOS too.
// https://gist.github.com/jimmckeeth/2c66e7c4fee55d56ad9928606f6cc197
unit MultiPlatformCryptoRandom;

interface

uses System.Classes, System.SysUtils;

function CryptoRandomCardinal: Cardinal;
function CryptoRandomFloat: Single;
function CryptoRandomRange(max: Cardinal): Cardinal;

implementation

{$IFDEF MSWindows}

uses WinAPI.Security.Cryptography;
{$ENDIF}

function CryptoRandomRange(max: Cardinal): Cardinal;
begin
  Result := CryptoRandomCardinal mod max;
end;

function CryptoRandomFloat: Single;
begin
  Result := CryptoRandomCardinal / 4294967295;
end;

function CryptoRandomCardinal: Cardinal;
begin
{$IFDEF MSWindows}
  var
  b := TCryptographicBuffer.Create;
  try
    Result := b.GenerateRandomNumber;
  finally
    b.Free;
  end;
{$ENDIF}
{$IFDEF POSIX}
  var
  RandomStream := TFileStream.Create('/dev/urandom', fmOpenRead);
  try
    RandomStream.Read(Result, SizeOf(Result));
  finally
    RandomStream.Free;
  end;
{$ENDIF}
end;

end.
