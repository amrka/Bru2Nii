unit main;

{$ifdef fpc}{$mode objfpc}{$H+} {$endif}

interface

uses
 {$ifdef fpc} Process, strutils, FileUtil, ZStream, {$endif}
 {$ifndef fpc} ShellAPI,messages, strutils, {$endif}
  SysUtils, Forms, Controls, Dialogs, Buttons,
  StdCtrls, ExtCtrls, Classes, mat;
type
  { TForm1 }
  TForm1 = class(TForm)
    AppendSeriesTypeIDCheck: TCheckBox;
    CompressFileCheck: TCheckBox;
    ConvertBtn: TButton;
    ConvertLabel: TLabel;
    FOVx10Check: TCheckBox;
    OnlyConvert3DCheck: TCheckBox;
    VerboseCheck: TCheckBox;
    AppendProtocolNameCheck: TCheckBox;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    procedure ConvertBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ConvertFile(FName: string);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    {$ifndef fpc} procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES; {$endif}
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation
{$ifdef fpc}
 {$R *.lfm}
{$else}
 {$R *.DFM}
{$endif}
{ TForm1 }

procedure Showmsg(lStr: string);
begin
   Form1.Memo1.lines.Add(lStr);
end;

{$include common.inc}

procedure TForm1.ConvertFile(FName: string);
begin
   {$ifdef fpc}
   BrConvertBatch (FName,'', FOVx10Check.checked, VerboseCheck.Checked, OnlyConvert3DCheck.Checked, AppendProtocolNameCheck.Checked, AppendSeriesTypeIDCheck.Checked, CompressFileCheck.checked);
   {$else}
   BrConvertBatch (FName,'', FOVx10Check.checked, VerboseCheck.Checked, OnlyConvert3DCheck.Checked, AppendProtocolNameCheck.Checked, AppendSeriesTypeIDCheck.Checked, false);
   {$endif}
end;

procedure TForm1.ConvertBtnClick(Sender: TObject);
begin
     opendialog1.Filter := '"subject" or "acqp"|subject;acqp';
     opendialog1.Title:='Select  Bruker format file';
     if not opendialog1.Execute then exit;
     Form1.Memo1.lines.Clear;
     ConvertFile (opendialog1.FileName);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     Showmsg(kVers);
     {$ifdef fpc}
     DefaultFormatSettings.DecimalSeparator := '.';  //e.g. German users write "1,23", but Bruker requires "1.23"
     {$else}
     DragAcceptFiles(Handle, True);
     DecimalSeparator := '.';  //e.g. German users write "1,23", but Bruker requires "1.23"
     {$endif}
end;

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of String);
var
   lI: integer;
begin
     Form1.Memo1.lines.Clear;
     for lI := 0 to (length(FileNames)-1) do
         ConvertFile(Filenames[lI]);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
     //BrConvertBatch ('/Users/rorden/tst/2','/Users/rorden/tst', FOVx10Check.checked, VerboseCheck.Checked, OnlyConvert3DCheck.Checked, AppendProtocolNameCheck.Checked, AppendSeriesTypeIDCheck.Checked);
end;

{$ifndef fpc}
procedure TForm1.WMDropFiles(var Msg: TWMDropFiles);  //implement drag and drop
const
  MAX_PATH = 1024;
var  CFileName: array[0..MAX_PATH] of Char;
begin
  try
    if DragQueryFile(Msg.Drop, 0, CFileName, MAX_PATH) > 0 then begin
      ConvertFile(CFilename);
      Msg.Result := 0;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end; //WMDropFiles
{$endif}

end.

