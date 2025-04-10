// https://github.com/martinusso/ulid/blob/master/ULID.pas
// Edited by https://github.com/VTwo-Group
unit ULID;

interface

{
  ULID: Universally Unique Lexicographically Sortable Identifier

  String Representation: ttttttttttrrrrrrrrrrrrrrrr
  where t is Timestamp
  r is Randomness

  For more information see: https://github.com/martinusso/ulid/blob/master/README.md
}

function Generate: string;
function EncodeTime(Time: Int64): string;
function DecodeULIDDateTime(const ULID: string): TDateTime;

implementation

uses
  DateUtils,
  SysUtils,
  Windows,
  MultiPlatformCryptoRandom;

const
  // Crockford's Base32
  ENCODING: array [0 .. 31] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K',
    'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z');
  ENCODING_LENGTH = Length(ENCODING);
  ENCODED_RANDOM_LENGTH = 16;
  ENCODED_TIME_LENGTH = 10;

function EncodeRandom: string;
var
  I: Word;
  Rand: Integer;
begin
  Result := '';
  for I := ENCODED_RANDOM_LENGTH downto 1 do
  begin
    // Trunc(ENCODING_LENGTH * Random);
    Rand := CryptoRandomRange(ENCODING_LENGTH);
    Result := ENCODING[Rand] + Result;
  end;
end;

function Generate: string;
  function UNIXTimeInMilliseconds: Int64;
  var
    ST: SystemTime;
    DT: TDateTime;
  begin
    GetSystemTime(ST);
    DT := EncodeDate(ST.wYear, ST.wMonth, ST.wDay) + SysUtils.EncodeTime(ST.wHour, ST.wMinute, ST.wSecond, ST.wMilliseconds);
    Result := DateUtils.MilliSecondsBetween(DT, UnixDateDelta);
  end;

begin
  Result := EncodeTime(UNIXTimeInMilliseconds) + EncodeRandom;
end;

function EncodeTime(Time: Int64): string;
var
  I: Word;
  M: Integer;
begin
  Result := '';
  for I := ENCODED_TIME_LENGTH downto 1 do
  begin
    M := (Time mod ENCODING_LENGTH);
    Result := ENCODING[M] + Result;
    Time := Trunc((Time - M) / ENCODING_LENGTH);
  end;
end;

function DecodeULIDDateTime(const ULID: string): TDateTime;
var
  I: Integer;
  CharIndex: Integer;
  TimeValue: Int64;
  TimePart: string;
begin
  TimeValue := 0;
  TimePart := Copy(ULID, 1, ENCODED_TIME_LENGTH);

  for I := 1 to Length(TimePart) do
  begin
    CharIndex := Pos(TimePart[I], string(ENCODING)) - 1;
    if CharIndex < 0 then
      raise Exception.CreateFmt('Invalid character "%s" in ULID timestamp part.', [TimePart[I]]);
    TimeValue := TimeValue * ENCODING_LENGTH + CharIndex;
  end;

  Result := UnixDateDelta + (TimeValue / 1000.0 / SecsPerDay);
end;

end.
