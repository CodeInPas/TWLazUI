unit TwLazUI.Stepper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math, LCLIntf,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIStepper }
  TTwLazUIStepper = class(TCustomControl)
  private
    FSteps: TStrings;
    FCurrentStep: Integer;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;

    procedure SetSteps(AValue: TStrings);
    procedure SetCurrentStep(AValue: Integer);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);

    procedure StepsChanged(Sender: TObject);
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
    property AutoSize default True;
    property BorderSpacing;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentBackground default True;
    property Visible;

    property Steps: TStrings read FSteps write SetSteps;
    property CurrentStep: Integer read FCurrentStep write SetCurrentStep default 0;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;

    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUIStepper }

constructor TTwLazUIStepper.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csParentBackground] - [csOpaque, csAcceptsControls];
  ParentBackground := True;

  Width := 400;
  Height := 65;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FCurrentStep := 1;

  FSteps := TStringList.Create;
  TStringList(FSteps).OnChange := @StepsChanged;

  if csDesigning in ComponentState then
  begin
    FSteps.Add('Cart');
    FSteps.Add('Shipping');
    FSteps.Add('Payment');
    FSteps.Add('Review');
  end;

  AutoSize := True;
end;

destructor TTwLazUIStepper.Destroy;
begin
  FSteps.Free;
  inherited Destroy;
end;

procedure TTwLazUIStepper.SetSteps(AValue: TStrings);
begin
  FSteps.Assign(AValue);
end;

procedure TTwLazUIStepper.StepsChanged(Sender: TObject);
begin
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIStepper.SetCurrentStep(AValue: Integer);
begin
  if FCurrentStep = AValue then Exit;
  if (FSteps <> nil) and (FSteps.Count > 0) then
    FCurrentStep := EnsureRange(AValue, 0, FSteps.Count - 1)
  else
    FCurrentStep := Max(0, AValue);

  Invalidate;
end;

procedure TTwLazUIStepper.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIStepper.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIStepper.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
begin
  PreferredHeight := 65;

  if (FSteps <> nil) and (FSteps.Count > 0) then
    PreferredWidth := 80 + ((FSteps.Count - 1) * 120)
  else
    PreferredWidth := 200;
end;

procedure TTwLazUIStepper.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUIStepper.Paint;
var
  Bmp: TBGRABitmap;
  ctx: TBGRACanvas2D;
  i, ValidCount: Integer;
  ActiveColor, LineColor: TColor;
  Radius, YCenter, LeftPad, RightPad, StepWidth, CX, CY, StartX, EndX: Single;
  TempFont: TFont;
  StepText: string;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  TempFont := TFont.Create;
  try
    TempFont.Assign(Font);

    ActiveColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
    if FThemeColor = twCustom then ActiveColor := FCustomColor;
    if not Enabled then ActiveColor := twSlate400;

    ValidCount := 0;
    if FSteps <> nil then ValidCount := FSteps.Count;

    if ValidCount = 0 then
    begin
      Bmp.Draw(Canvas, 0, 0, False);
      Exit;
    end;

    Radius := 14;
    YCenter := 20;
    LeftPad := 40;
    RightPad := 40;

    if ValidCount > 1 then
      StepWidth := (Width - LeftPad - RightPad) / (ValidCount - 1)
    else
      StepWidth := 0;

    for i := 0 to ValidCount - 2 do
    begin
      StartX := LeftPad + (i * StepWidth);
      EndX := LeftPad + ((i + 1) * StepWidth);

      if i < FCurrentStep then
        LineColor := ActiveColor
      else
        LineColor := twSlate200;

      Bmp.DrawLineAntialias(StartX, YCenter, EndX, YCenter, ColorToBGRA(LineColor), 2);
    end;

    for i := 0 to ValidCount - 1 do
    begin
      CX := LeftPad + (i * StepWidth);
      CY := YCenter;
      StepText := FSteps[i];

      if i < FCurrentStep then
      begin
        Bmp.FillEllipseAntialias(CX, CY, Radius, Radius, ColorToBGRA(ActiveColor));

        ctx := Bmp.Canvas2D;
        ctx.beginPath;
        ctx.strokeStyle(ColorToBGRA(twWhite));
        ctx.lineWidth := 2;
        ctx.lineCap := 'round';
        ctx.lineJoin := 'round';
        ctx.moveTo(CX - 4, CY);
        ctx.lineTo(CX - 1, CY + 4);
        ctx.lineTo(CX + 5, CY - 4);
        ctx.stroke;

        TempFont.Style := [fsBold];
        TTwGraphics.DrawText(Bmp, Rect(Round(CX-50), Round(CY+Radius+8), Round(CX+50), Height), StepText, TempFont, twSlate800, taCenter, tlTop);
      end
      else if i = FCurrentStep then
      begin
        Bmp.FillEllipseAntialias(CX, CY, Radius + 4, Radius + 4, ColorToBGRA(ActiveColor, 50));
        Bmp.FillEllipseAntialias(CX, CY, Radius, Radius, ColorToBGRA(ActiveColor));

        TempFont.Style := [fsBold];
        TTwGraphics.DrawText(Bmp, Rect(Round(CX-Radius), Round(CY-Radius), Round(CX+Radius), Round(CY+Radius)), IntToStr(i+1), TempFont, twWhite, taCenter, tlCenter);

        TTwGraphics.DrawText(Bmp, Rect(Round(CX-50), Round(CY+Radius+8), Round(CX+50), Height), StepText, TempFont, twSlate900, taCenter, tlTop);
      end
      else
      begin
        // PERBAIKAN: Menggunakan teknik penumpukan lingkaran (stacking) untuk efek outline border
        Bmp.FillEllipseAntialias(CX, CY, Radius, Radius, ColorToBGRA(twSlate300));
        Bmp.FillEllipseAntialias(CX, CY, Radius - 2, Radius - 2, BGRAWhite);

        TempFont.Style := [];
        TTwGraphics.DrawText(Bmp, Rect(Round(CX-Radius), Round(CY-Radius), Round(CX+Radius), Round(CY+Radius)), IntToStr(i+1), TempFont, twSlate400, taCenter, tlCenter);

        TTwGraphics.DrawText(Bmp, Rect(Round(CX-50), Round(CY+Radius+8), Round(CX+50), Height), StepText, TempFont, twSlate500, taCenter, tlTop);
      end;
    end;

    Bmp.Draw(Canvas, 0, 0, False);
  finally
    TempFont.Free;
    Bmp.Free;
  end;
end;

end.
