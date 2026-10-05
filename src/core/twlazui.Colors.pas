unit TwLazUI.Colors;

{$mode objfpc}{$H+}

interface

uses
  Graphics, SysUtils, TwLazUI.Types;

type
  { TTwColorPalette:
    Fungsi utilitas statis untuk resolusi warna dan tema komponen }
  TTwColorPalette = class
  public
    class function HexToColor(const HexStr: string): TColor; static;
    class function GetBaseColor(Theme: TTwThemeColor; Shade: Integer): TColor; static;
    class function GetBgColor(Theme: TTwThemeColor; State: TTwState; Variant: TTwVariant; CustomColor: TColor = clNone): TColor; static;
    class function GetTextColor(Theme: TTwThemeColor; State: TTwState; Variant: TTwVariant; CustomColor: TColor = clNone): TColor; static;
    class function GetBorderColor(Theme: TTwThemeColor; State: TTwState; Variant: TTwVariant; CustomColor: TColor = clNone): TColor; static;
  end;

const
  // Palette Utama (Format Lazarus TColor: $00BBGGRR)

  // Slate (Neutral / Secondary)
  twSlate50  = $00FCFAF8;
  twSlate100 = $00F9F5F1;
  twSlate200 = $00F0E8E2;
  twSlate300 = $00E1D5CB;
  twSlate400 = $00B8A394;
  twSlate500 = $008B7464;
  twSlate600 = $00695547;
  twSlate700 = $00554133;
  twSlate800 = $003B291E;
  twSlate900 = $002A170F;

  // Blue (Primary)
  twBlue50   = $00FAEDEB;
  twBlue100  = $00F8D2CE;
  twBlue200  = $00F4BAA5;
  twBlue300  = $00FDC593;
  twBlue400  = $00F8A360;
  twBlue500  = $00F6823B;
  twBlue600  = $00EB6325;
  twBlue700  = $00D84E1D;
  twBlue800  = $00B2441E;
  twBlue900  = $008B3D1E;

  // Green (Success)
  twGreen50  = $00F0FDF4;
  twGreen100 = $00DCFCE7;
  twGreen200 = $00BBF7D0;
  twGreen300 = $0086EFAC;
  twGreen400 = $004ADE80;
  twGreen500 = $005EC522;
  twGreen600 = $004AA316;
  twGreen700 = $003D8015;
  twGreen800 = $00346516;
  twGreen900 = $002D5314;

  // Red (Danger)
  twRed50  = $00F2F2FE;
  twRed100 = $00E6E6FE;
  twRed200 = $00C9C9FE;
  twRed300 = $00A5A5FC;
  twRed400 = $007171F8;
  twRed500 = $004444EF;
  twRed600 = $002626DC;
  twRed700 = $001C1CB9;
  twRed800 = $001B1B99;
  twRed900 = $001A1A7F;

  // Yellow (Warning)
  twYellow50  = $00E4FEFE;
  twYellow100 = $00C3FDFE;
  twYellow200 = $008AF9FE;
  twYellow300 = $0047E0FD;
  twYellow400 = $000ECCFA;
  twYellow500 = $0008B3EA;
  twYellow600 = $00048ACA;
  twYellow700 = $000762A1;
  twYellow800 = $000F4E85;
  twYellow900 = $00133F71;

  // Sky (Info)
  twSky50  = $00F9FAFC;
  twSky100 = $00F0F9E0;
  twSky200 = $00E0F2BA;
  twSky300 = $00FCD37D;
  twSky400 = $00F4BA38;
  twSky500 = $00E9A50E;
  twSky600 = $00C78402;
  twSky700 = $00A16903;
  twSky800 = $00825307;
  twSky900 = $006B440C;

  // Neutral (Light/Dark)
  twWhite       = $00FFFFFF;
  twBlack       = $00000000;
  twTransparent = clNone;

implementation

class function TTwColorPalette.HexToColor(const HexStr: string): TColor;
var
  CleanHex: string;
begin
  CleanHex := StringReplace(HexStr, '#', '', [rfReplaceAll]);
  if Length(CleanHex) = 6 then
    // Convert RRGGBB to Lazarus TColor format $00BBGGRR
    Result := StringToColor('$' + Copy(CleanHex, 5, 2) + Copy(CleanHex, 3, 2) + Copy(CleanHex, 1, 2))
  else if Length(CleanHex) = 3 then
    Result := StringToColor('$' + Copy(CleanHex, 3, 1) + Copy(CleanHex, 3, 1) +
                                  Copy(CleanHex, 2, 1) + Copy(CleanHex, 2, 1) +
                                  Copy(CleanHex, 1, 1) + Copy(CleanHex, 1, 1))
  else
    Result := clNone;
end;

class function TTwColorPalette.GetBaseColor(Theme: TTwThemeColor; Shade: Integer): TColor;
begin
  case Theme of
    twPrimary:
      case Shade of
        50: Result := twBlue50; 100: Result := twBlue100; 200: Result := twBlue200;
        300: Result := twBlue300; 400: Result := twBlue400; 500: Result := twBlue500;
        600: Result := twBlue600; 700: Result := twBlue700; 800: Result := twBlue800;
        900: Result := twBlue900; else Result := twBlue500;
      end;
    twSecondary:
      case Shade of
        50: Result := twSlate50; 100: Result := twSlate100; 200: Result := twSlate200;
        300: Result := twSlate300; 400: Result := twSlate400; 500: Result := twSlate500;
        600: Result := twSlate600; 700: Result := twSlate700; 800: Result := twSlate800;
        900: Result := twSlate900; else Result := twSlate500;
      end;
    twSuccess:
      case Shade of
        50: Result := twGreen50; 100: Result := twGreen100; 200: Result := twGreen200;
        300: Result := twGreen300; 400: Result := twGreen400; 500: Result := twGreen500;
        600: Result := twGreen600; 700: Result := twGreen700; 800: Result := twGreen800;
        900: Result := twGreen900; else Result := twGreen500;
      end;
    twDanger:
      case Shade of
        50: Result := twRed50; 100: Result := twRed100; 200: Result := twRed200;
        300: Result := twRed300; 400: Result := twRed400; 500: Result := twRed500;
        600: Result := twRed600; 700: Result := twRed700; 800: Result := twRed800;
        900: Result := twRed900; else Result := twRed500;
      end;
    twWarning:
      case Shade of
        50: Result := twYellow50; 100: Result := twYellow100; 200: Result := twYellow200;
        300: Result := twYellow300; 400: Result := twYellow400; 500: Result := twYellow500;
        600: Result := twYellow600; 700: Result := twYellow700; 800: Result := twYellow800;
        900: Result := twYellow900; else Result := twYellow500;
      end;
    twInfo:
      case Shade of
        50: Result := twSky50; 100: Result := twSky100; 200: Result := twSky200;
        300: Result := twSky300; 400: Result := twSky400; 500: Result := twSky500;
        600: Result := twSky600; 700: Result := twSky700; 800: Result := twSky800;
        900: Result := twSky900; else Result := twSky500;
      end;
    twLight:
      case Shade of
        500: Result := twSlate100; 600: Result := twSlate200; 700: Result := twSlate300;
        else Result := twWhite;
      end;
    twDark:
      case Shade of
        500: Result := twSlate800; 600: Result := twSlate900; 700: Result := twBlack;
        else Result := twSlate800;
      end;
    else
      Result := twWhite;
  end;
end;

class function TTwColorPalette.GetBgColor(Theme: TTwThemeColor; State: TTwState; Variant: TTwVariant; CustomColor: TColor): TColor;
begin
  if Theme = twCustom then Exit(CustomColor);

  case Variant of
    twVariantSolid:
      case State of
        twStateNormal: Result := GetBaseColor(Theme, 500);
        twStateHover: Result := GetBaseColor(Theme, 600);
        twStateActive: Result := GetBaseColor(Theme, 700);
        twStateDisabled: Result := GetBaseColor(Theme, 300);
        twStateFocused: Result := GetBaseColor(Theme, 500);
        else Result := GetBaseColor(Theme, 500);
      end;
    twVariantOutline, twVariantGhost, twVariantLink:
      case State of
        twStateHover: Result := GetBaseColor(Theme, 50);
        twStateActive: Result := GetBaseColor(Theme, 100);
        else Result := twTransparent;
      end;
    else
      Result := clNone;
  end;
end;

class function TTwColorPalette.GetTextColor(Theme: TTwThemeColor; State: TTwState; Variant: TTwVariant; CustomColor: TColor): TColor;
begin
  if State = twStateDisabled then
    Exit(twSlate400);

  case Variant of
    twVariantSolid:
      begin
        if (Theme = twLight) or (Theme = twCustom) then
          Result := twSlate800
        else
          Result := twWhite;
      end;
    twVariantOutline, twVariantGhost, twVariantLink:
      case State of
        twStateHover, twStateActive: Result := GetBaseColor(Theme, 700);
        else Result := GetBaseColor(Theme, 600);
      end;
    else
      Result := twBlack;
  end;
end;

class function TTwColorPalette.GetBorderColor(Theme: TTwThemeColor; State: TTwState; Variant: TTwVariant; CustomColor: TColor): TColor;
begin
  if Theme = twCustom then Exit(CustomColor);

  case Variant of
    twVariantSolid, twVariantOutline:
      case State of
        twStateDisabled: Result := GetBaseColor(Theme, 200);
        twStateHover: Result := GetBaseColor(Theme, 600);
        twStateActive: Result := GetBaseColor(Theme, 700);
        twStateFocused: Result := GetBaseColor(Theme, 400);
        else Result := GetBaseColor(Theme, 500);
      end;
    else
      Result := twTransparent;
  end;
end;

end.
