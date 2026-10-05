unit TwLazUI.Graphics;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Types, BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors;

type
  { TTwGraphics:
    Kelas utilitas untuk melakukan rendering grafis tingkat lanjut menggunakan BGRABitmap }
  TTwGraphics = class
  public
    class function GetRadius(Style: TTwRoundedStyle; ControlHeight: Integer): Single; static;
    class procedure DrawShadow(Canvas: TBGRABitmap; Rect: TRect; Radius: Single; Shadow: TTwShadow; Color: TColor = clBlack); static;
    class procedure DrawBackground(Canvas: TBGRABitmap; Rect: TRect; Radius: Single; BgColor: TColor); static;
    class procedure DrawBorder(Canvas: TBGRABitmap; Rect: TRect; Radius: Single; BorderColor: TColor; Width: Integer = 1; Style: TTwBorderStyle = twBorderSolid); static;
    class procedure DrawText(Canvas: TBGRABitmap; Rect: TRect; const Text: string; Font: TFont; TextColor: TColor; Alignment: TAlignment; Layout: TTextLayout = tlCenter); static;
  end;

implementation

class function TTwGraphics.GetRadius(Style: TTwRoundedStyle; ControlHeight: Integer): Single;
begin
  case Style of
    twRoundedSM: Result := 2;
    twRoundedMD: Result := 4;
    twRoundedLG: Result := 8;
    twRoundedXL: Result := 12;
    twRoundedFull: Result := ControlHeight / 2;
    else Result := 0; // twRoundedNone
  end;
end;

class procedure TTwGraphics.DrawShadow(Canvas: TBGRABitmap; Rect: TRect; Radius: Single; Shadow: TTwShadow; Color: TColor = clBlack);
var
  Blur, OffsetY: Integer;
  Opacity: Byte;
  TempBMP, BlurBMP: TBGRABitmap;
begin
  if Shadow = twShadowNone then Exit;

  // Konfigurasi ketebalan dan kedalaman bayangan (TwLazUI Spec)
  case Shadow of
    twShadowSM: begin Blur := 2; OffsetY := 1; Opacity := 12; end;
    twShadowMD: begin Blur := 4; OffsetY := 2; Opacity := 20; end;
    twShadowLG: begin Blur := 8; OffsetY := 4; Opacity := 25; end;
    twShadowXL: begin Blur := 15; OffsetY := 8; Opacity := 30; end;
    twShadowInner: Exit; // Inner shadow ditangani terpisah jika diperlukan
  else
    Exit;
  end;

  // Render bayangan dengan memburamkan kotak transparan (BlurRadial)
  TempBMP := TBGRABitmap.Create(Canvas.Width, Canvas.Height);
  try
    if Radius > 0 then
      // Gunakan Round(Radius) untuk menghindari overload error antara Integer/Single overload resolution
      TempBMP.FillRoundRect(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, Round(Radius), Round(Radius), ColorToBGRA(Color, Opacity), dmSet)
    else
      TempBMP.FillRect(Rect, ColorToBGRA(Color, Opacity), dmSet);

    BlurBMP := TempBMP.FilterBlurRadial(Blur, rbFast) as TBGRABitmap;
    try
      Canvas.BlendImage(0, OffsetY, BlurBMP, boLinearBlend);
    finally
      BlurBMP.Free;
    end;
  finally
    TempBMP.Free;
  end;
end;

class procedure TTwGraphics.DrawBackground(Canvas: TBGRABitmap; Rect: TRect; Radius: Single; BgColor: TColor);
begin
  if BgColor = clNone then Exit;

  if Radius > 0 then
    // Gunakan FillRoundRectAntialias yang natively mendukung tipe floating point (Single)
    Canvas.FillRoundRectAntialias(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, Radius, Radius, ColorToBGRA(BgColor))
  else
    Canvas.FillRect(Rect, ColorToBGRA(BgColor), dmDrawWithTransparency);
end;

class procedure TTwGraphics.DrawBorder(Canvas: TBGRABitmap; Rect: TRect; Radius: Single; BorderColor: TColor; Width: Integer; Style: TTwBorderStyle);
var
  ctx: TBGRACanvas2D;
begin
  if (BorderColor = clNone) or (Width <= 0) or (Style = twBorderNone) then Exit;

  // Menggunakan HTML5 Canvas API dari BGRABitmap untuk garis batas presisi
  ctx := Canvas.Canvas2D;
  ctx.lineWidth := Width;

  // strokeStyle di BGRACanvas2D adalah sebuah prosedur, bukan properti assignment (:=)
  ctx.strokeStyle(ColorToBGRA(BorderColor));

  ctx.beginPath;
  if Radius > 0 then
    ctx.roundRect(Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top, Radius)
  else
    ctx.rect(Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
  ctx.stroke;
end;

class procedure TTwGraphics.DrawText(Canvas: TBGRABitmap; Rect: TRect; const Text: string; Font: TFont; TextColor: TColor; Alignment: TAlignment; Layout: TTextLayout);
begin
  if Text = '' then Exit;

  Canvas.FontName := Font.Name;
  if Font.Size > 0 then
    Canvas.FontHeight := -Round(Font.Size * 96 / 72)
  else
    Canvas.FontHeight := Font.Height;

  Canvas.FontStyle := Font.Style;
  Canvas.FontAntialias := True;

  Canvas.TextRect(Rect, Text, Alignment, Layout, ColorToBGRA(TextColor));
end;

end.
