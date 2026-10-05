unit TwLazUI.Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Graphics, Forms;

type
  { TTwUtils:
    Fungsi utilitas untuk tata letak, skalabilitas DPI, dan perhitungan warna }
  TTwUtils = class
  public
    class function Scale(AValue: Integer): Integer; inline; static;
    class function ScaleRect(const ARect: TRect): TRect; static;
    class function ShrinkRect(const ARect: TRect; const AAmount: Integer): TRect; inline; static;
    class function CenterRect(const AContainer: TRect; AWidth, AHeight: Integer): TRect; static;
    class function IsDarkColor(AColor: TColor): Boolean; static;
  end;

implementation

class function TTwUtils.Scale(AValue: Integer): Integer;
begin
  if (Screen <> nil) and (Screen.PixelsPerInch <> 96) then
    Result := (AValue * Screen.PixelsPerInch) div 96
  else
    Result := AValue;
end;

class function TTwUtils.ScaleRect(const ARect: TRect): TRect;
begin
  Result.Left := Scale(ARect.Left);
  Result.Top := Scale(ARect.Top);
  Result.Right := Scale(ARect.Right);
  Result.Bottom := Scale(ARect.Bottom);
end;

class function TTwUtils.ShrinkRect(const ARect: TRect; const AAmount: Integer): TRect;
begin
  Result.Left := ARect.Left + AAmount;
  Result.Top := ARect.Top + AAmount;
  Result.Right := ARect.Right - AAmount;
  Result.Bottom := ARect.Bottom - AAmount;
end;

class function TTwUtils.CenterRect(const AContainer: TRect; AWidth, AHeight: Integer): TRect;
begin
  Result.Left := AContainer.Left + ((AContainer.Right - AContainer.Left) - AWidth) div 2;
  Result.Top := AContainer.Top + ((AContainer.Bottom - AContainer.Top) - AHeight) div 2;
  Result.Right := Result.Left + AWidth;
  Result.Bottom := Result.Top + AHeight;
end;

class function TTwUtils.IsDarkColor(AColor: TColor): Boolean;
var
  RGB: Longint;
begin
  RGB := ColorToRGB(AColor);
  { Menggunakan Integer Math (tanpa float) untuk efisiensi maksimal.
    Berdasarkan rumus luminance Y = 0.299R + 0.587G + 0.114B.
    Batas tengah 0.5 dipetakan ke 127500 (255 * 500) }
  Result := ((Red(RGB) * 299) + (Green(RGB) * 587) + (Blue(RGB) * 114)) < 127500;
end;

end.

