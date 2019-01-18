unit ACBrEscPosChequeToshiba;

interface

uses Classes, ACBrPosPrinter, {$IFDEF MSWINDOWS} Dialogs, {$ENDIF} SysUtils;

type
  TACBrEscPosChequeToshiba = class(TACBrEscPosChequeClass)
  private type
    TPrintStatus = (psChequePosicionado);
    TPrintStatusSets = set of TPrintStatus;
  function InternoChequeConcluido: boolean;
  procedure LigaEstacaoCheque;
  procedure DesligaEstacaoCheque;
  procedure EjetarDocumento;
  protected
    FXML: String;
    FVirarCheque: boolean;
    FUltimoStatus: TPrintStatusSets;
    function GetChequeProntoClass: boolean; override;
    function LerStatus: TPrintStatusSets;
  public
    constructor create(AOwner: TACBrPosPrinter); override;
    function PosPrinter: TACBrPosPrinter;
    Procedure ImprimeCheque(Banco: String; Valor: Double;
      Favorecido, Cidade: String; Data: TDateTime;
      Observacao: String = ''); override;
    Procedure CancelaImpressaoCheque; override;
    Function LerCMC7: AnsiString; override;

  end;

implementation

uses ACBrUtil, IniFiles, ACBrExtenso, DateUtils, ACBrConsts;

var
  FPCheque: TACBrEscPosChequeToshiba;

const
  TAMANHO_MAXIMO_LINHA_CHEQUE_FontB = 85;
  TAMANHO_MAXIMO_LINHA_CHEQUE_FontA = 68;

type
  TStringHelperX = record helper for
    String
    function asInteger: integer;
    function Max(value: integer): integer;
  end;

  TPosicaoCheque = record
    case boolean of
      true:
        (ColValor: array [1 .. 2] of Ansichar;
          LinValor: array [1 .. 2] of Ansichar;
          ColExt1: array [1 .. 2] of Ansichar;
          LinExt1: array [1 .. 2] of Ansichar;
          ColExt2: array [1 .. 2] of Ansichar;
          LinExt2: array [1 .. 2] of Ansichar;
          ColFavor: array [1 .. 2] of Ansichar;
          LinFavor: array [1 .. 2] of Ansichar;
          ColCidade: array [1 .. 2] of Ansichar;
          LinCidade: array [1 .. 2] of Ansichar;
          ColDia: array [1 .. 2] of Ansichar;
          ColMes: array [1 .. 2] of Ansichar;
          ColAno: array [1 .. 2] of Ansichar;
          ColMsg: array [1 .. 2] of Ansichar;
          LinMsg: array [1 .. 2] of Ansichar);
      false:
        (texto: array [1 .. 50] of Ansichar);
  end;

procedure TACBrEscPosChequeToshiba.ImprimeCheque(Banco: String; Valor: Double;
  Favorecido, Cidade: String; Data: TDateTime; Observacao: String);

var
  pos: TPosicaoCheque;
  extenso: TACBrExtenso;
  sExtenso: string;
  sExtenso1: string;
  sExtenso2: string;
  FMatriz: Array [1 .. 14] of string;
  procedure CarregaPosicao;
  var
    x: integer;
    sPos: string;
  begin
    // inicializa a matriz do cheque;
    for x := Low(FMatriz) to High(FMatriz) do
      FMatriz[x] := PadLeft('', TAMANHO_MAXIMO_LINHA_CHEQUE_FontA, ' ');
    with TIniFile.create(ArquivoPosCheque) do
      try
        sPos := readString('FormatoCheque', Banco, '');
        if sPos = '' then
          sPos := readString('FormatoCheque', '000', '');
      finally
        free;
      end;

    if sPos = '' then
    begin
      sPos := '58,02,12,03,01,06,05,07,35,09,52,58,68,25,10';
    end;

    WriteLog(ArqLog, 'Layout de cheque<' + Banco + '> "' + sPos + '" em: ' +
      ArquivoPosCheque);

    sPos := StringReplace(sPos, ',', '', [rfReplaceAll]);

    sPos := copy(sPos, 1, sizeof(pos.texto));
    FillChar(pos, sizeof(pos), #0);

    for x := 1 to length(sPos) do
      if sPos[x] <> ';' then
        pos.texto[x] := Ansichar(sPos[x]);

  end;

  procedure FillMatriz(ALin: String; ACol: String; texto: string);
  var
    x, i, mx: integer;
    LLin,LCol:integer;
  begin
    if texto = '' then
      exit;
    LLin := strToIntDef(ALin,0);
    LCol := strToIntDef(ACol,0)-2;
    if LLin < 1 then
      LLin := 1;
    if LCol < 1 then
      LCol := 1;
    if (LCol+length(texto)) > TAMANHO_MAXIMO_LINHA_CHEQUE_FontA  then
       LCol := TAMANHO_MAXIMO_LINHA_CHEQUE_FontA - length(texto);
    mx := LCol + length(texto);
    if mx > TAMANHO_MAXIMO_LINHA_CHEQUE_FontA then
      mx := TAMANHO_MAXIMO_LINHA_CHEQUE_FontA;
    i := 1;
    for x := LCol to mx do
    begin
      FMatriz[LLin][x] := texto[i];
      inc(i);
    end;
  end;

  procedure quebraLinhaExtenso(s: string; ATamanhoExt1: integer);
  var
    rst: string;
    x: integer;
    mx: integer;
  begin
    mx := ATamanhoExt1;
    rst := copy(s, 1, mx);
    if (length(s) > mx) then
    begin
      for x := length(rst) downto 1 do
      begin
        if rst[x] = ' ' then
        begin
          rst := copy(s, 1, x - 1);
          break;
        end;
      end;
    end;
    sExtenso1 := rst;
    sExtenso2 := '';
    if rst <> s then
    begin
      sExtenso2 := copy(s, length(sExtenso1) + 1);
    end;
  end;

var
  cmd: string;
  procedure ImprimirCmd(var texto: AnsiString);
  begin
    FPosPrinter.ImprimirCmd(texto);
  end;

var
  desligar: boolean;
  function mask(c: char): string;
  var
    i: integer;
  begin
    result := '1';
    for i := 1 to 8 do
      result := result + PadRight(c, 9, c) + inttoStr(i);
    result := result + c + c + c + c;
  end;

const
  fontB = ESC + '!' + #2;
  fontA = ESC + '!' + #0;
var
  s: string;
  i: integer;
begin
  CarregaPosicao;
  desligar := CheckAtivar;
  try
    //FPosPrinter.ImprimirCmd(FPosPrinterClass.cmd.Zera);
    LigaEstacaoCheque;
    try
      FPosPrinter.ImprimirCmd(ESC + '!' + #1);

      // monta o extenso
      extenso := TACBrExtenso.create(nil);
      try
        sExtenso := TiraAcentos(extenso.ValorToTexto(Valor));
      finally
        extenso.free;
      end;
      quebraLinhaExtenso('###' + sExtenso + '###',
        TAMANHO_MAXIMO_LINHA_CHEQUE_FontA - StrToIntDef(pos.ColExt1, 10));

      if Observacao <> '' then
        FillMatriz(pos.LinMsg, pos.ColMsg, Observacao);

      FillMatriz(pos.LinCidade, pos.ColCidade, Cidade);
      FillMatriz(pos.LinCidade, pos.ColDia, dayOf(Data).ToString);
      FillMatriz(pos.LinCidade, pos.ColMes, formatDateTime('mmmm', Data));
      FillMatriz(pos.LinCidade, pos.ColAno, formatDateTime('YY', Data));

      // manda favorecido
      FillMatriz((StrToInt(pos.LinFavor)).ToString, pos.ColFavor, Favorecido);
      FillMatriz((StrToInt(pos.LinExt2)).ToString, pos.ColExt2, sExtenso2);
      FillMatriz((StrToInt(pos.LinExt1)).ToString, pos.ColExt1, sExtenso1);
      // manda o valor
      s := FormatFloat('0.00', Valor);
      FillMatriz((StrToInt(pos.LinValor)).ToString, pos.ColValor, s);
      for i := high(FMatriz) downto low(FMatriz) do
        if trim(FMatriz[i]) = '' then
          FPosPrinter.ImprimirCmd(LF)
        else
          FPosPrinter.ImprimirCmd(FMatriz[i]);
      FPosPrinter.ImprimirCmd(FPosPrinterClass.cmd.FonteNormal);
    finally
      EjetarDocumento;
    end;

  finally
    CheckDesativar(not desligar);
  end;

end;
// *)

procedure TACBrEscPosChequeToshiba.CancelaImpressaoCheque;
var
  ret: AnsiString;
begin
  inherited;
  DesligaEstacaoCheque;
end;

function TACBrEscPosChequeToshiba.InternoChequeConcluido: boolean;
var
  ret: AnsiString;
begin
  CheckAtivar;
  try
    result := false;
    LerStatus;
    result := not(psChequePosicionado in FUltimoStatus);
  finally
    CheckDesativar();
  end;
end;

constructor TACBrEscPosChequeToshiba.create(AOwner: TACBrPosPrinter);
begin
  inherited;
  FPCheque := self;
  // ArquivoPosCheque := ExtractFilePath(ParamStr(0)) + 'checkLayouts.xml';
  // arquivo fornecido pela toshiba
end;

procedure TACBrEscPosChequeToshiba.DesligaEstacaoCheque;
begin
  CheckAtivar;
  try
    // #define CMD_SET_PRINT_SATATION_CR "\x1B\x63\x30\x02"
    FPosPrinter.ImprimirCmd(#$1B + #$63 + #$30 + #$2);
  finally
    CheckDesativar();
  end;
end;

procedure TACBrEscPosChequeToshiba.EjetarDocumento;
begin
  LigaEstacaoCheque;
  try
    FPosPrinter.ImprimirCmd(ESC + #$69);
  finally
    DesligaEstacaoCheque;
  end;
end;

function TACBrEscPosChequeToshiba.GetChequeProntoClass: boolean;
var
  ret: AnsiString;
  desligar: boolean;
begin
  desligar := CheckAtivar;
  try
    result := false;
    LerStatus;
    if psChequePosicionado in FUltimoStatus then
    begin
      result := true;
    end;
  finally
    CheckDesativar(not desligar);
  end;
end;

function TACBrEscPosChequeToshiba.LerCMC7: AnsiString;
var
  LRetorno: AnsiString;
  LSair: boolean;
  LTimeOut: TDateTime;
  LLenBytes: integer;
  LControlePorta: boolean;
  desligar: boolean;
begin
  if not ChequePronto then
    exit;
  desligar := CheckAtivar;
  try
    LControlePorta := FPosPrinter.controlePorta;
    FPosPrinter.controlePorta := false;
    FPosPrinter.device.Limpar;

    // LigaEstacaoCheque;
    try
      FPosPrinter.ImprimirCmd(ESC + 'I');
      // Read check paper
      LSair := false;
      LTimeOut := IncMilliSecond(now, 5000);
      LLenBytes := 0;
      LRetorno := '';
      repeat
        if FPosPrinter.device.BytesParaLer > 0 then
        begin
          LRetorno := LRetorno + FPosPrinter.device.LeString(100);
          if length(LRetorno) <> LLenBytes then
          begin
            LTimeOut := IncMilliSecond(now, 5000);
            LLenBytes := length(LRetorno);
          end;
        end;
        if ((LLenBytes > 30) and (LRetorno[length(LRetorno)] in [#0, 'a'])) then
          break;
        if LTimeOut < now then
          LSair := true;
      until LSair;

      if (length(LRetorno) > 0) then
      begin
        result := StringReplace(copy(LRetorno, length(LRetorno) - 35, 36), ' ',
          '', [rfReplaceAll]);

        if FVirarCheque then // comentado para nao virar o cheque exit;
          FPosPrinter.ImprimirCmd(ESC + '5');

      end;
      (*
        case 19:
        {
        unsigned int bytesWritten = 0;
        unsigned char cmdEjetarDocumento[2] = {0x1B, 0x69};
        unsigned char cmdEstacaoCheque[4] = {0x1B, 0x63, 0x30, 0x08};

        //SELECIONA ESTACAO
        ret = _Write(cmdEstacaoCheque, sizeof(cmdEstacaoCheque), &bytesWritten);

        //EJETAR DOCUMENTO
        ret = _Write(cmdEjetarDocumento, sizeof(cmdEjetarDocumento), &bytesWritten);
        if(ret == 0)
        {
        printf(">> Funcao Executada com Sucesso (%d) <<\n\n", ret);
        }else
        {
        printf(">> Erro na Execucao da Funcao (%d) <<\n\n", ret);
        }
        }
        break;
      *)
      EjetarDocumento;
    finally
      FPosPrinter.controlePorta := LControlePorta;
    end;
  finally
    CheckDesativar(not desligar);
  end;
end;

function TACBrEscPosChequeToshiba.LerStatus: TPrintStatusSets;
var
  statusByte: array [1 .. 16] of byte;
  nBytes: integer;
  B: AnsiString;

  procedure convToBytes(dados: string; var bytes: array of byte);
  var
    i, n: integer;
  begin
    n := 0;
    for i := low(dados) to high(dados) do
    begin
      bytes[n] := ord(dados[i]);
      inc(n);
    end;
  end;

begin
  CheckAtivar;
  try
    result := [];
    FillChar(statusByte, sizeof(statusByte), #0);

    B := FPosPrinter.TxRx(DLE + ENQ + '4', 2, 100);
    // na 1NR retorna 10, na 2NR retorna 16 ?
    if length(B) <> 2 then
      raise exception.create('Esperava 2 chrs');
    nBytes := ((ord(B[1]) * 16) + ord(B[2]) - 2);
    B := FPosPrinter.device.LeString(100, nBytes);
    convToBytes(copy(B, 1, nBytes), statusByte);

    if not TestBit(statusByte[2], 1) then
      result := result + [psChequePosicionado];

    FUltimoStatus := result;
  finally
    CheckDesativar();
  end;

end;

procedure TACBrEscPosChequeToshiba.LigaEstacaoCheque;
begin
  CheckAtivar;
  try
    FPosPrinter.ImprimirCmd(#$1B + #$63 + #$30 + #$8);
    // #define CMD_SET_PRINT_SATATION_DI_LANDSCAPE "\x1B\x63\x30\x08"
    // #define CMD_SET_PRINT_SATATION_DI_PORTRAIT "\x1B\x63\x30\x04"
  finally
    CheckDesativar();
  end;
end;

function TACBrEscPosChequeToshiba.PosPrinter: TACBrPosPrinter;
begin
  result := FPosPrinter;
end;

{ TStringHelperX }

function TStringHelperX.asInteger: integer;
begin
  result := StrToIntDef(self, 0);
end;

function TStringHelperX.Max(value: integer): integer;
begin
  result := asInteger;
  if result > value then
    result := value;
end;

end.
