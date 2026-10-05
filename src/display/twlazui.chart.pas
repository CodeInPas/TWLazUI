unit TwLazUI.Chart;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math, LCLIntf,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  // PERBAIKAN: Definisikan tipe array dinamis secara eksplisit agar bisa digunakan sebagai tipe kembalian fungsi
  TPointFArray = array of TPointF;

  { TTwLazUILineChart }
  TTwLazUILineChart = class(TCustomControl)
  private
    FData: TStrings;
    FTitle: string;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FYMin: Double;
    FYMax: Double;
    FYStep: Double;
    FYPrefix: string;
    FYSuffix: string;
    FSmoothCurve: Boolean;
    FShowFill: Boolean;
    FRoundedStyle: TTwRoundedStyle;

    procedure SetData(AValue: TStrings);
    procedure SetTitle(const AValue: string);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetYMin(AValue: Double);
    procedure SetYMax(AValue: Double);
    procedure SetYStep(AValue: Double);
    procedure SetYPrefix(const AValue: string);
    procedure SetYSuffix(const AValue: string);
    procedure SetSmoothCurve(AValue: Boolean);
    procedure SetShowFill(AValue: Boolean);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);

    procedure DataChanged(Sender: TObject);
    function GetSmoothPoints(const DataPts: array of TPointF): TPointFArray; // PERBAIKAN: Gunakan TPointFArray
  protected
    procedure Paint; override;
    procedure EraseBackground(DC: HDC); override;
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property BorderSpacing;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentBackground default True;
    property Visible;

    property Data: TStrings read FData write SetData;
    property Title: string read FTitle write SetTitle;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property YMin: Double read FYMin write SetYMin;
    property YMax: Double read FYMax write SetYMax;
    property YStep: Double read FYStep write SetYStep;
    property YPrefix: string read FYPrefix write SetYPrefix;
    property YSuffix: string read FYSuffix write SetYSuffix;
    property SmoothCurve: Boolean read FSmoothCurve write SetSmoothCurve default True;
    property ShowFill: Boolean read FShowFill write SetShowFill default True;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedLG;

    property OnClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ TTwLazUILineChart }

constructor TTwLazUILineChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csParentBackground] - [csOpaque];
  ParentBackground := True;

  Width := 500;
  Height := 350;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FData := TStringList.Create;
  TStringList(FData).OnChange := @DataChanged;

  FTitle := 'Monthly revenue';
  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FYMin := 0;
  FYMax := 50;
  FYStep := 10; // Akan menyesuaikan visual 50k, 45k, dst
  FYPrefix := '$';
  FYSuffix := 'k';
  FSmoothCurve := True;
  FShowFill := True;
  FRoundedStyle := twRoundedLG;

  // Data Default saat Desain
  if csDesigning in ComponentState then
  begin
    FData.Add('Jan=28');
    FData.Add('Feb=34');
    FData.Add('Mar=31');
    FData.Add('Apr=39');
    FData.Add('May=42');
    FData.Add('Jun=48');
    FYStep := 5; // Rentang tiap 5k untuk menyamai TwLazUI
  end;
end;

destructor TTwLazUILineChart.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

procedure TTwLazUILineChart.SetData(AValue: TStrings);
begin
  FData.Assign(AValue);
end;

procedure TTwLazUILineChart.DataChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TTwLazUILineChart.SetTitle(const AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetYMin(AValue: Double);
begin
  if FYMin = AValue then Exit;
  FYMin := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetYMax(AValue: Double);
begin
  if FYMax = AValue then Exit;
  FYMax := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetYStep(AValue: Double);
begin
  if FYStep = AValue then Exit;
  FYStep := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetYPrefix(const AValue: string);
begin
  if FYPrefix = AValue then Exit;
  FYPrefix := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetYSuffix(const AValue: string);
begin
  if FYSuffix = AValue then Exit;
  FYSuffix := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetSmoothCurve(AValue: Boolean);
begin
  if FSmoothCurve = AValue then Exit;
  FSmoothCurve := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetShowFill(AValue: Boolean);
begin
  if FShowFill = AValue then Exit;
  FShowFill := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUILineChart.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
begin
  // Chart biasanya di-resize oleh pengguna, tidak AutoSize
  PreferredWidth := 500;
  PreferredHeight := 350;
end;

procedure TTwLazUILineChart.EraseBackground(DC: HDC);
begin
  // Hindari flicker
end;

function TTwLazUILineChart.GetSmoothPoints(const DataPts: array of TPointF): TPointFArray; // PERBAIKAN: Gunakan TPointFArray
var
  i, j, Steps, Idx: Integer;
  t, InvT: Single;
  P1, P2, CP1, CP2: TPointF;
begin
  if Length(DataPts) < 2 then
  begin
    SetLength(Result, Length(DataPts));
    for i := 0 to High(DataPts) do Result[i] := DataPts[i];
    Exit;
  end;

  Steps := 20; // 20 Segmen per garis untuk hasil yang sangat mulus
  SetLength(Result, (Length(DataPts) - 1) * Steps + 1);
  Idx := 0;

  for i := 0 to High(DataPts) - 1 do
  begin
    P1 := DataPts[i];
    P2 := DataPts[i+1];

    // Algoritma Monotone Cubic untuk Chart
    CP1 := PointF((P1.X + P2.X) / 2, P1.Y);
    CP2 := PointF((P1.X + P2.X) / 2, P2.Y);

    for j := 0 to Steps - 1 do
    begin
      t := j / Steps;
      InvT := 1.0 - t;
      Result[Idx].X := (InvT * InvT * InvT * P1.X) +
                       (3 * InvT * InvT * t * CP1.X) +
                       (3 * InvT * t * t * CP2.X) +
                       (t * t * t * P2.X);
      Result[Idx].Y := (InvT * InvT * InvT * P1.Y) +
                       (3 * InvT * InvT * t * CP1.Y) +
                       (3 * InvT * t * t * CP2.Y) +
                       (t * t * t * P2.Y);
      Inc(Idx);
    end;
  end;
  Result[Idx] := DataPts[High(DataPts)];
end;

procedure TTwLazUILineChart.Paint;
var
  Bmp: TBGRABitmap;
  GraphRect, BtnRect: TRect;
  GraphLeft, GraphRight, GraphTop, GraphBottom, GraphHeight: Integer;
  i: Integer;
  Val, CurY: Double;
  YPos, XPos, XGap: Single;
  YStr, XStr: string;
  ActiveColor, GridColor, TextColor: TColor;
  DataPts, DrawPts, PolyPts: array of TPointF;
  TempFont: TFont;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  TempFont := TFont.Create;
  try
    TempFont.Assign(Font);

    // Warna Dasar
    ActiveColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
    if FThemeColor = twCustom then ActiveColor := FCustomColor;
    GridColor := twSlate200;
    TextColor := twSlate500;

    // 1. Gambar Container Card
    GraphRect := Rect(0, 0, Width, Height);
    TTwGraphics.DrawBackground(Bmp, GraphRect, TTwGraphics.GetRadius(FRoundedStyle, Height), twWhite);
    TTwGraphics.DrawBorder(Bmp, GraphRect, TTwGraphics.GetRadius(FRoundedStyle, Height), twSlate800, 1, twBorderSolid);

    GraphLeft := 60;
    GraphRight := Width - 30;
    GraphTop := 80;
    GraphBottom := Height - 50;
    GraphHeight := GraphBottom - GraphTop;

    // 2. Gambar Judul Chart
    TempFont.Style := [fsBold];
    TempFont.Size := 11;
    TTwGraphics.DrawText(Bmp, Rect(25, 25, 200, 50), FTitle, TempFont, twSlate900, taLeftJustify, tlCenter);

    // 3. Gambar Filter Button Dummy (6M | 12M) seperti di referensi
    BtnRect := Rect(GraphRight - 90, 25, GraphRight, 53);
    TTwGraphics.DrawBackground(Bmp, BtnRect, 6, twWhite);
    TTwGraphics.DrawBorder(Bmp, BtnRect, 6, twSlate800, 1, twBorderSolid);
    Bmp.DrawLineAntialias(GraphRight - 45, 25, GraphRight - 45, 53, ColorToBGRA(twSlate800), 1);
    TempFont.Style := [];
    TempFont.Size := 9;
    TTwGraphics.DrawText(Bmp, Rect(BtnRect.Left, BtnRect.Top, BtnRect.Left+45, BtnRect.Bottom), '6M', TempFont, twSlate800, taCenter, tlCenter);
    TTwGraphics.DrawText(Bmp, Rect(BtnRect.Left+45, BtnRect.Top, BtnRect.Right, BtnRect.Bottom), '12M', TempFont, twSlate800, taCenter, tlCenter);

    TempFont.Size := 10; // Reset font size untuk label

    // 4. Gambar Grid Horizontal & Label Y
    if FYStep > 0 then
    begin
      CurY := FYMin;
      while CurY <= FYMax do
      begin
        YPos := GraphBottom - ((CurY - FYMin) / Max(0.001, FYMax - FYMin)) * GraphHeight;

        // Garis Grid
        Bmp.DrawLineAntialias(GraphLeft, YPos, GraphRight, YPos, ColorToBGRA(GridColor), 1);

        // Teks Y-Axis
        YStr := FYPrefix + FloatToStr(CurY) + FYSuffix;
        TTwGraphics.DrawText(Bmp, Rect(10, Round(YPos) - 10, GraphLeft - 10, Round(YPos) + 10), YStr, TempFont, TextColor, taRightJustify, tlCenter);

        CurY := CurY + FYStep;
      end;
    end;

    // 5. Kalkulasi & Gambar Data Line
    if FData.Count > 0 then
    begin
      SetLength(DataPts, FData.Count);
      if FData.Count > 1 then
        XGap := (GraphRight - GraphLeft) / (FData.Count - 1)
      else
        XGap := 0;

      for i := 0 to FData.Count - 1 do
      begin
        XPos := GraphLeft + (i * XGap);
        Val := StrToFloatDef(FData.ValueFromIndex[i], 0);

        if Val > FYMax then Val := FYMax;
        if Val < FYMin then Val := FYMin;

        YPos := GraphBottom - ((Val - FYMin) / Max(0.001, FYMax - FYMin)) * GraphHeight;
        DataPts[i] := PointF(XPos, YPos);

        // Teks X-Axis
        XStr := FData.Names[i];
        if XStr = '' then XStr := FData[i]; // Fallback
        TTwGraphics.DrawText(Bmp, Rect(Round(XPos) - 20, GraphBottom + 10, Round(XPos) + 20, GraphBottom + 30), XStr, TempFont, TextColor, taCenter, tlCenter);
      end;

      if FSmoothCurve then
        DrawPts := GetSmoothPoints(DataPts)
      else
        DrawPts := DataPts;

      // Fill Area Bawah Kurva
      if FShowFill and (Length(DrawPts) > 0) then
      begin
        SetLength(PolyPts, Length(DrawPts) + 2);
        for i := 0 to High(DrawPts) do PolyPts[i] := DrawPts[i];

        // Tutup polygon ke bawah
        PolyPts[Length(DrawPts)] := PointF(DrawPts[High(DrawPts)].X, GraphBottom);
        PolyPts[Length(DrawPts) + 1] := PointF(DrawPts[0].X, GraphBottom);

        // Alpha transparansi 40 untuk fill
        Bmp.FillPolyAntialias(PolyPts, ColorToBGRA(ActiveColor, 40));
      end;

      // Gambar Garis Kurva
      Bmp.DrawPolyLineAntialias(DrawPts, ColorToBGRA(ActiveColor), 2);
    end;

    Bmp.Draw(Canvas, 0, 0, False);
  finally
    TempFont.Free;
    Bmp.Free;
  end;
end;

end.
