{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit twlazui_components;

{$warn 5023 off : no warning about unused units}
interface

uses
  twlazui.Types, twlazui.Colors, twlazui.Utils, twlazui.Graphics, 
  twlazui.Badge, twlazui.Avatar, twlazui.ProgressBar, twlazui.Alert, 
  twlazui.Spinner, twlazui.Skeleton, twlazui.Toast, twlazui.ListBox, 
  twlazui.ComboBox, twlazui.TrackBar, twlazui.TabControl, twlazui.Breadcrumb, 
  twlazui.Accordion, twlazui.Sidebar, twlazui.StringGrid, 
  twlazui.ModalOverlay, twlazui.Tooltip, twlazui.PopupMenu, twlazui.Button, 
  twlazui.CheckBox, twlazui.RadioButton, twlazui.Switch, TWLazUI_reg, 
  TwLazUI.Panel, TwLazUI.SLabel, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('TWLazUI_reg', @TWLazUI_reg.Register);
end;

initialization
  RegisterPackage('twlazui_components', @Register);
end.
