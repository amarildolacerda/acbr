{ ****************************************************************************** }
{ Projeto: Componentes ACBr }
{ Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
{ mentos de Automação Comercial utilizados no Brasil }

{ Direitos Autorais Reservados (c) 2004 Daniel Simoes de Almeida }

{ Colaboradores nesse arquivo: }

{ Você pode obter a última versão desse arquivo na pagina do  Projeto ACBr }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr }

{ Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
{ sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela }
{ Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
{ qualquer versão posterior. }

{ Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM }
{ NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU }
{ ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor }
{ do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT) }

{ Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto }
{ com esta biblioteca; se não, escreva para a Free Software Foundation, Inc., }
{ no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA. }
{ Você também pode obter uma copia da licença em: }
{ http://www.opensource.org/licenses/gpl-license.php }

{ Daniel Simões de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br }
{ Praça Anita Costa, 34 - Tatuí - SP - 18270-410 }

{ ****************************************************************************** }

{ ******************************************************************************
  |* Historico
  |*
  |* 20/04/2013:  Daniel Simões de Almeida
  |*   Inicio do desenvolvimento
  |* 12/08/2016: -Copiado da EscPosEpson - Inicio compatibilidade com Toshiba (por: amarildo lacerda)
  ****************************************************************************** }

{$I ACBr.inc}
unit ACBrEscToshiba;

interface

uses
  Classes, SysUtils, ACBrPosPrinter, ACBrDevice;

type

  { TACBrEscPosToshiba }

  TACBrEscToshiba = class(TACBrPosPrinterClass)
  private
    FUltimoInfo: string;
    FLeuInfo: boolean;
    procedure DoTratarImprimir(const AString: AnsiString;
      var AStringTratada: AnsiString);
  public
    constructor Create(AOwner: TACBrPosPrinter);

    function ComandoCodBarras(const ATag: String; ACodigo: AnsiString)
      : AnsiString; override;
    function ComandoQrCode(ACodigo: AnsiString): AnsiString; override;
    function ComandoEspacoEntreLinhas(Espacos: Byte): AnsiString; override;
    function ComandoPaginaCodigo(APagCodigo: TACBrPosPaginaCodigo)
      : AnsiString; override;
    function ComandoLogo: AnsiString; override;
    function ComandoGaveta(NumGaveta: Integer = 1): AnsiString; override;

    procedure LerStatus(var AStatus: TACBrPosPrinterStatus); override;
    function LerInfo: String; override;
  end;

implementation

uses
  strutils, math, system.DateUtils,
  ACBrConsts, ACBrUtil;

{ TACBrEscPosToshiba }

constructor TACBrEscToshiba.Create(AOwner: TACBrPosPrinter);
begin
  inherited Create(AOwner);

  // AOwner.OnTratarImprimir := DoTratarImprimir;

  RazaoColunaFonte.Condensada := 0.85;
  RazaoColunaFonte.Expandida := 2;

  if assigned(AOwner) then
    if AOwner.ColunasFonteNormal > 44 then
      AOwner.ColunasFonteNormal := 44;
  fpModeloStr := 'EscToshiba';

  { (* }
  with Cmd do
  begin
    Zera := ESC + '@'; // + DLE + ENQ + '1';
    PuloDeLinha := LF;
    EspacoEntreLinhasPadrao := ESC + '1'; // '';//ESC + '2';
    EspacoEntreLinhas := ESC + '3';
    FonteNormal := ESC + '!' + #0;
    FonteA := ESC + '!' + #0;
    FonteB := ESC + '!' + #2;
    LigaNegrito := ESC + 'G' + #1;
    DesligaNegrito := ESC + 'G' + #0;
    LigaExpandido := ESC + 'W' + #1; // OK
    DesligaExpandido := ESC + 'W' + #0; // OK
    LigaSublinhado := ESC + '-' + #1; // OK
    DesligaSublinhado := ESC + '-' + #0; // OK
    LigaInvertido := ESC + 'H' + #1;
    DesligaInvertido := ESC + 'H' + #0;
    LigaItalico := ESC + '!' + #0; // Não existe ?
    DesligaItalico := ESC + '!' + #0; // Não existe ?
    LigaCondensado := FonteB;
    DesligaCondensado := FonteA;
    AlinhadoEsquerda := ESC + 'a' + #0;
    AlinhadoCentro := ESC + 'a' + #1;
    AlinhadoDireita := ESC + 'a' + #2;
    CorteTotal := ESC + 'i';
    CorteParcial := ESC + 'm';
    Beep := ESC + BELL + '05' + #12;
  end;
  { *) }

  TagsNaoSuportadas.Add(cTagBarraMSI);

end;

procedure TACBrEscToshiba.DoTratarImprimir(const AString: AnsiString;
  var AStringTratada: AnsiString);
begin
  // remove o LF do texto (estava saltando uma linha em branco) - amarildo lacerda
  AStringTratada := stringReplace(AString, #13#10, #13, [rfReplaceAll])
end;

function TACBrEscToshiba.ComandoCodBarras(const ATag: String;
  ACodigo: AnsiString): AnsiString;
var
  L, A, M: Integer;
  CmdBarCode: Char;
  ACodBar, Cmd128, Code128c: AnsiString;
  i, s: Integer;
begin

  { if ATag = cTagBarraUPCA then
    CmdBarCode := 'A'
    else if ATag = cTagBarraUPCE then
    CmdBarCode := 'B'
    else if ATag = cTagBarraEAN13 then
    CmdBarCode := 'C'
    else if ATag = cTagBarraEAN8 then
    CmdBarCode := 'D'
    else } if ATag = cTagBarraCode39 then
    CmdBarCode := #4
    { else if ATag = cTagBarraInter then
      CmdBarCode := 'F'
      else if ATag = cTagBarraCodaBar then
      CmdBarCode := 'G'
      else if ATag = cTagBarraCode93 then
      CmdBarCode := 'H'
      else if (ATag = cTagBarraCode128) or (ATag = cTagBarraCode128b) then
      begin
      CmdBarCode := 'I';
      Cmd128 := '{B';
      end
      else if ATag = cTagBarraCode128a then
      begin
      CmdBarCode := 'I';
      Cmd128 := '{A';
      end
    } else if ATag = cTagBarraCode128c then
  begin
    CmdBarCode := #7;
    // Cmd128 := '{C';

    // Apenas números,
    ACodigo := AnsiString(OnlyNumber(String(ACodigo)));

    s := Length(ACodigo);
    if s mod 2 <> 0 then // Tamanho deve ser Par
    begin
      ACodigo := '0' + ACodigo;
      Inc(s);
    end;

    { Code128c := '';
      i := 1;
      while i < s do
      begin
      Code128c := Code128c + AnsiChr(StrToInt(copy(String(ACodigo), i, 2)));
      i := i + 2;
      end;

      ACodigo := Code128c;
    }
  end
  { else if ATag = cTagBarraMSI then // Apenas Bematech suporta
    CmdBarCode := 'R' }
  else
  begin
    Result := ACodigo;
    Exit;
  end;

  // ACodBar := ACodigo;

  with fpPosPrinter.ConfigBarras do
  begin
    L := IfThen(LarguraLinha = 0, 2, max(min(LarguraLinha, 4), 1));
    A := IfThen(Altura = 0, 50, max(min(Altura, 255), 1));
    M := IfThen(MostrarCodigo, 2, 0);
  end;

  Result := GS + 'w' + AnsiChr(L) + // Largura
    GS + 'h' + AnsiChr(A) + // altura
    GS + 'k' + CmdBarCode + ACodigo + #0;

  { Result := GS + 'w' + AnsiChr(L) + // Largura
    GS + 'h' + AnsiChr(A) + // Altura
    GS + 'H' + AnsiChr(M) + // HRI (numero impresso abaixo do cod.barras)
    GS + 'k' + CmdBarCode + AnsiChr(Length(ACodBar)) + ACodBar;
  }
end;

function TACBrEscToshiba.ComandoQrCode(ACodigo: AnsiString): AnsiString;
var
  encode: Char;
  error: Char;
  eci: Char;
begin
  encode := #5;
  error := #0; // reduz o tamanho
  eci := #26;
  with fpPosPrinter.ConfigQRCode do
  begin
    if errorLevel < 0 then
      errorLevel := 0
    else if errorLevel > 3 then
      errorLevel := 3;
    error := Char(errorLevel);
    Result := GS + 'O' + encode + error + eci + ACodigo + #0;
  end;

end;

function TACBrEscToshiba.ComandoEspacoEntreLinhas(Espacos: Byte): AnsiString;
begin
  if Espacos = 0 then
    Result := Cmd.EspacoEntreLinhasPadrao
  else
    Result := Cmd.EspacoEntreLinhas + AnsiChr(Espacos);
end;

function TACBrEscToshiba.ComandoPaginaCodigo(APagCodigo: TACBrPosPaginaCodigo)
  : AnsiString;
var
  CmdPag: Integer;
begin
   case APagCodigo of
    pc437: CmdPag := 0;
    pc850: CmdPag := 1;
    pc852: CmdPag := 1;
    pc860: CmdPag := 3;
    pc1252: CmdPag := $13;
    else
    begin
    Result := '';
    Exit;
    end;
    end;

    Result := ESC + 't' + AnsiChr( CmdPag );

end;

function TACBrEscToshiba.ComandoLogo: AnsiString;
begin
  { with fpPosPrinter.ConfigLogo do
    begin
    Result := GS + '(L' + #6 + #0 + #48 + #69 +
    AnsiChr(KeyCode1) + AnsiChr(KeyCode2) +
    AnsiChr(FatorX)   + AnsiChr(FatorY);
    end;
  }
end;

function TACBrEscToshiba.ComandoGaveta(NumGaveta: Integer): AnsiString;
var
  CharGav: AnsiChar;
begin
  if NumGaveta > 1 then
    CharGav := '1'
  else
    CharGav := '0';

  with fpPosPrinter.ConfigGaveta do
  begin
    Result := ESC + 'p' + CharGav + AnsiChar(TempoON) + AnsiChar(TempoOFF);
  end;
end;

procedure TACBrEscToshiba.LerStatus(var AStatus: TACBrPosPrinterStatus);
var
  nBytes: Integer;
  B: AnsiString;
  Falhas: Integer;
  statusByte: array [1 .. 16] of Byte;
  procedure convToBytes(dados: string; var bytes: array of Byte);
  var
    i, n: Integer;
  begin
    n := 0;
    for i := low(dados) to high(dados) do
    begin
      bytes[n] := ord(dados[i]);
      Inc(n);
    end;
  end;

begin
  LerInfo;
  // nao implementado
  // Exit;

  if not(fpPosPrinter.Device.IsSerialPort or fpPosPrinter.Device.IsTCPPort) then
    Exit;
  AStatus := [];
  Falhas := 0;
  while Falhas < 5 do
  begin
    try
      // os bits iniciam na posição 1  (o manual é base ZERO)
      //
      fpPosPrinter.Ativo := True;
      fillchar(statusByte, sizeof(statusByte), #0);

      B := fpPosPrinter.TxRx(DLE + ENQ + '4', 2, 100);
      // na 1NR retorna 10, na 2NR retorna 16 ?
      if Length(B) <> 2 then
        raise Exception.Create('Esperava 2 chrs');
      nBytes := min((ord(B[1]) * 16) + ord(B[2]) - 2, 14);
      B := fpPosPrinter.Device.LeString(100, nBytes);
      convToBytes(copy(B, 1, nBytes), statusByte);

      if TestBit(statusByte[1], 6) or TestBit(statusByte[11], 4) or
      // #define tampaAberta(status) (status[0] & BIT6)
        TestBit(statusByte[12], 4) then // tampa aberta
        AStatus := AStatus + [stTampaAberta];

      if TestBit(statusByte[1], 1) then
        AStatus := AStatus + [stImprimindo];

      if TestBit(statusByte[7], 3) then
        // #define gavetaAberta(status) (status[6] & BIT3)
        AStatus := AStatus + [stGavetaAberta]; // testado OK;

      if TestBit(statusByte[9], 7) then
        AStatus := AStatus + [stOffLine]; // na 1NR nao funciona

      if TestBit(statusByte[9], 7) { erro } or
        TestBit(statusByte[3], 1) { full }
        or TestBit(statusByte[3], 7) { firmer error }
      then
        AStatus := AStatus + [stErro];

      {
        #define semPapelTermico(status) (status[7] & BIT5)
        #define papelTermicoNivelCritico(status) (status[10] & BIT7)
        #define poucoPapelTermico(status) (status[10] & BIT6)
      }

      if TestBit(statusByte[11], 6) or TestBit(statusByte[11], 7) then
        AStatus := AStatus + [stPoucoPapel];

      if TestBit(statusByte[8], 5) then
        AStatus := AStatus + [stSemPapel]; // testado OK

      Break;
    except
      Inc(Falhas);
      if Falhas >= 5 then;
      AStatus := AStatus + [stErro];
    end;
  end;

end;

function TACBrEscToshiba.LerInfo: String;
var
  LAtivo: boolean;
  Ret: AnsiString;
  nBytes: Integer;
  Info: String;
  B: Byte;
  statusByte: array [1 .. 33] of Byte;
  procedure convToBytes(dados: string; var bytes: array of Byte);
  var
    i, n: Integer;
  begin
    n := 0;
    for i := low(dados) to high(dados) do
    begin
      bytes[n] := ord(dados[i]);
      Inc(n);
    end;
  end;

  Procedure AddInfo(Titulo: String; AInfo: AnsiString);
  begin
    Info := Info + Titulo + '=' + AInfo + sLineBreak;
  end;

begin
  if FLeuInfo then
  begin
    Result := FUltimoInfo;
    Exit;
  end;

  LAtivo := fpPosPrinter.Ativo;
  try

    // restaura a estação principal - de cupom
    // #define CMD_SET_PRINT_SATATION_CR "\x1B\x63\x30\x02"
    fpPosPrinter.ImprimirCmd(#$1B + #$63 + #$30 + #$2);

    Info := '';
    AddInfo('Fabricante', 'Toshiba');
    AddInfo('Gaveta', '1');
    AddInfo('Guilhotina', '1');
    AddInfo('Firmware', '0001');
    AddInfo('Serial', '1');

    if not fpPosPrinter.Ativo then
      fpPosPrinter.Ativar;

    Ret := fpPosPrinter.TxRx(#$1D + #$49 + #$1, 2, 500);
    nBytes := ord(Ret[1]) * 16 + ord(Ret[2]) - 2;
    Ret := fpPosPrinter.Device.LeString(100, nBytes);
    convToBytes(Ret, statusByte);

    if statusByte[7] = 0 then
      AddInfo('Modelo', '4610-1CR')
    else
      AddInfo('Modelo', '4610-2CR');

    AddInfo('MICR', IfThen(pos('4610-2CR', Info) > 0, '1', '0'));
    AddInfo('Cheque', IfThen(pos('4610-2CR', Info) > 0, '1', '0'));

    Result := Info;
    FUltimoInfo := Result;
    FLeuInfo := True;

  finally
    if not LAtivo then
      fpPosPrinter.Desativar;
  end;

end;

(*
  procedure TACBrEscPosToshiba.ProgramarLogo(ALogoFileBMP: String);
  var
  AFileStream: TFileStream;
  ABitMap: TBitmap;
  Col, Row, W, H, P: Integer;
  ACmd: AnsiString;
  begin
  // Inspiração: http://stackoverflow.com/questions/13715950/writing-a-bitmap-to-epson-tm88iv-through-esc-p-commands-write-to-nvram

  ABitMap := TBitmap.Create;
  AFileStream := TFileStream.Create(ALogoFileBMP, fmOpenRead);
  try
  AFileStream.Position := 0;
  ABitMap.LoadFromStream(AFileStream);

  W := ABitMap.Width;
  H := ABitMap.Height;

  ACmd := #48 + #67 + #48 + 'AC' + #01 +
  IntToLEStr(W) +
  IntToLEStr(H) +
  #49;  // 1 Cor, Mono

  For Col := 0 to W do
  For Row := 0 to H do
  begin
  P := ABitMap.Canvas.Pixels[Col, Row];
  ACmd := ACmd + AnsiChr( P );
  end;

  ACmd := GS + 'L(' + IntToLEStr(Length(ACmd)) + ACmd;

  fpPosPrinter.ImprimirCmd( ACmd ) ;

  fpPosPrinter.ImprimirCmd( GS  + '(L' + #6 + #0 + #48 + #69 + 'AC' + #01 + #01 );

  finally
  AFileStream.Free;
  ABitMap.Free;
  end;
  end;
*)
end.
