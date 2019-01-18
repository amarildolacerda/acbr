unit ACBrEscPosChequeEpson;

interface

uses Classes, ACBrPosPrinter, {$IFDEF MSWINDOWS} Dialogs, {$ENDIF} SysUtils;

type
  TACBrEscPosChequeEpson = class(TACBrEscPosChequeClass)
  private
    function InternoChequeConcluido: boolean;

  protected
    function GetChequeProntoClass: boolean; override;
  public
    Procedure ImprimeCheque(Banco: String; Valor: Double;
      Favorecido, Cidade: String; Data: TDateTime;
      Observacao: String = ''); override;
    Procedure CancelaImpressaoCheque; override;
    Function LerCMC7: AnsiString; override;

  end;

implementation

uses IniFiles, ACBrExtenso, DateUtils, ACBrUtil, ACBrConsts;

{ TACBrEscPosChequeEpson }

type
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

const
  escLineSpaceOn = ESC + #51 + #30;
  escLineSpaceOff = ESC + '2';

procedure TACBrEscPosChequeEpson.ImprimeCheque(Banco: String; Valor: Double;
  Favorecido, Cidade: String; Data: TDateTime; Observacao: String);
var
  pos: TPosicaoCheque;
  sPos: AnsiString;
  x: integer;
  nLin: integer;
  pgCheque: string;
const
  ajustaColuna = 0;

  function espaco(x: string): string;
  begin
    result := padLeft('', strToIntDef(x, 0) + ajustaColuna, ' ');
  end;

const
  lgap = 0;
  nCols = 70;
  procedure PosicionaLinha(xLin: string);
  begin
    while (strToInt(xLin)) > nLin do
    begin
      // FPosPrinter.ImprimirCmd(#10#13{' ' + #10});
      pgCheque := pgCheque + #10#13;
      inc(nLin);
    end;
  end;

var
  extenso: TACBrExtenso;
  sExtenso: string;
  sExtenso1: string;
  sExtenso2: string;
  procedure quebraLinhaExtenso(s: string; posCol: integer);
  var
    rst: string;
    x: integer;
    mx: integer;
  begin
    mx := nCols - (posCol);
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
  desligar: boolean;
  procedure ImprimirCMD(texto: AnsiString);
  begin
    FPosPrinter.ImprimirCMD(texto);
  end;

begin
  desligar := CheckAtivar;
  try

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
        pos.texto[x] := sPos[x];

    nLin := 1;

    // Select the side of the slip (face or back).
    try

      ImprimirCMD(escLineSpaceOff + #13 { #10 } );
      ImprimirCMD(#29#40#71#2#0#48#4);

      try

        if not ChequePronto then
          exit;

        // Feed to the print starting position for the slip.
        ImprimirCMD(#29#40#71#2#0#84#1);

        // Select page mode
        ImprimirCMD(#27#76);

        // Set print area in page mode  //ImprimePorta(#27#87#00#00#00#00#240#01#79#03);
        // ImprimePorta(#27#87#00#00#90#00#255#02#79#03);
        ImprimirCMD(#27#87#00#00#00#00#255#03#79#03);

        // Select print direction in page mode
        ImprimirCMD(#27#84#03); // top to bottom

        // monta a folha de cheque
        pgCheque := '';
        PosicionaLinha(pos.LinValor);
        sPos := copy(space(lgap) + espaco(pos.ColValor) + '#' +
          formatFloat('0.00', Valor) + '#', 1, nCols);
        pgCheque := pgCheque + sPos;

        extenso := TACBrExtenso.create(nil);
        try
          sExtenso := TiraAcentos(extenso.ValorToTexto(Valor));
        finally
          extenso.free;
        end;
        quebraLinhaExtenso('###' + sExtenso + '###', strToInt(pos.ColExt1));

        PosicionaLinha(pos.LinExt1);
        sPos := copy(espaco(pos.ColExt1) + sExtenso1, 1, nCols);
        pgCheque := pgCheque + sPos;

        PosicionaLinha(pos.LinExt2);

        sPos := copy(espaco(pos.ColExt2) + sExtenso2, 1, nCols);
        pgCheque := pgCheque + sPos;

        PosicionaLinha(pos.LinFavor);
        if Favorecido = '' then
          Favorecido := ' ';
        sPos := copy(espaco(pos.ColFavor) + Favorecido, 1, nCols);
        pgCheque := pgCheque + sPos;

        PosicionaLinha(pos.LinCidade);
        sPos := PadRight(space(strToInt(pos.ColCidade)) + Cidade,
          strToInt(pos.ColDia), ' ');
        sPos := PadRight(sPos + formatDateTime('dd', Data),
          strToInt(pos.ColMes), ' ');
        sPos := PadRight(sPos + formatDateTime('mmmm', Data),
          strToInt(pos.ColAno), ' ');
        sPos := sPos + formatDateTime('yy', Data);

        sPos := copy(sPos, 1, nCols);
        pgCheque := pgCheque + sPos;

        if (Observacao <> '') and
          (strToIntDef(pos.LinMsg, 0) > strToInt(pos.LinCidade)) then
        begin
          PosicionaLinha(pos.LinMsg);
          quebraLinhaExtenso(Observacao, strToInt(pos.ColMsg));
          if sExtenso1 <> '' then
            pgCheque := pgCheque +
              (copy(space(strToInt(pos.ColMsg)) + sExtenso1, 1, nCols) +
              #13 { #10 } );
          if sExtenso2 <> '' then
          begin
            inc(nLin);
            pgCheque := pgCheque +
              (copy(space(strToInt(pos.ColMsg)) + sExtenso2, 1, nCols));
          end;
        end;
        ImprimirCMD(pgCheque);

        ImprimirCMD(#10);

        ImprimirCMD(#27#12); // Print data in page mode

      finally
        ImprimirCMD(#27#83);
        ImprimirCMD(#12); // Print and eject cut sheet

        try
          InternoChequeConcluido();
        finally
          ImprimirCMD(#27#99#48#1); // selecina estacao bobina
        end;

        ImprimirCMD(escLineSpaceOn);

      end;
    except
      raise;
    end;
  finally
      CheckDesativar(not desligar);
  end;
end;

procedure TACBrEscPosChequeEpson.CancelaImpressaoCheque;
var
  ret: AnsiString;
begin
  inherited;
  CheckAtivar;
  try
    FPosPrinter.ImprimirCMD(#16#20#8#1#3#20#1#6#2#8);
    // recuperar apos erro e limpa o buffer.
    FPosPrinter.ImprimirCMD(#27#99#48#1); // selecina estacao bobina
    FPosPrinter.ImprimirCMD(escLineSpaceOn);
  finally
    CheckDesativar();
  end;
end;

function TACBrEscPosChequeEpson.InternoChequeConcluido: boolean;
var
  ret: AnsiString;
begin
  CheckAtivar;
  try
  result := false;
  // timeout := GetTickCount + 10000;
  {
    FPosPrinter.device.EnviaString(#16#4#1); // Transmit real-time status
    // DebugLog('','Resposta1: <'+ StrToBin(fpRespostaComando)+'>'+intToStr(ord((fpRespostaComando+#0)[1]))  );

    FPosPrinter.device.EnviaString(#16#4#2); // Transmit real-time status
    // DebugLog('','Resposta2: <'+ StrToBIN(fpRespostaComando)+'>'+intToStr(ord((fpRespostaComando+#0)[1]))  );

    FPosPrinter.device.EnviaString(#16#4#3); // Transmit real-time status
    // DebugLog('','Resposta3: <'+ StrToBIN(fpRespostaComando)+'>'+intToStr(ord((fpRespostaComando+#0)[1]))  );

    FPosPrinter.device.EnviaString(#16#4#4); // Transmit real-time status
    // DebugLog('','Resposta4: <'+ StrToBIN(fpRespostaComando)+'>'+intToStr(ord((fpRespostaComando+#0)[1]))  );

    FPosPrinter.device.EnviaString(#16#4#6); // Transmit real-time status
    // DebugLog('','Resposta6: <'+ StrToBIN(fpRespostaComando)+'>'+intToStr(ord((fpRespostaComando+#0)[1]))  );
  }
  ret := FPosPrinter.TxRx(#16#4#5); // Transmit real-time status
  // DebugLog('','Resposta5: <'+ StrToBIN(fpRespostaComando)+'>'+intToStr(ord((fpRespostaComando+#0)[1]))  );

  if (ret <> '') and (TestBit(ord((ret + #0)[1]), 6) = true) then
  begin // Slip BOF sensor: paper present.
    result := true;
    // break;
  end;
  // showMessage('resposta3: '+fpRespostaComando);

  { if GetTickCount > timeout then // esgotou o tempo de impressão
    begin
    raise exception.Create('Timeout de impresssão do documento');
    break;
    end;
  }

  finally
    CheckDesativar();
  end;
end;

function TACBrEscPosChequeEpson.GetChequeProntoClass: boolean;
var
  ret: AnsiString;
begin
  CheckAtivar;
  try
    result := false;
    ret := FPosPrinter.TxRx(#16#4#5, 1, 500, false);
    if (length(ret) > 0) and (TestBit(ord(ret[1]), 5) = false) then
    begin
      result := true;
    end;
  finally
    CheckDesativar;
  end;
end;

function TACBrEscPosChequeEpson.LerCMC7: AnsiString;
var
  ret: AnsiString;
  fim: boolean;
  tm: TDateTime;
  lenBytes: integer;
  cp: boolean;
  desligar:boolean;
begin
  desligar:= CheckAtivar;
  try
  if not ChequePronto then
    exit;
  try
    cp := FPosPrinter.controlePorta;
    FPosPrinter.controlePorta := false;
    FPosPrinter.ImprimirCMD(#28#97#48#1); // Read check paper
    FPosPrinter.ImprimirCMD(#29#40#71#3#0#61#1#0);
    fim := false;
    tm := IncMilliSecond(now, 5000);
    lenBytes := 0;
    sleep(2000);
    repeat
      if FPosPrinter.device.BytesParaLer > 0 then
      begin
        ret := ret + FPosPrinter.device.LeString(100);
        if length(ret) <> lenBytes then
        begin
          tm := IncMilliSecond(now, 5000);
          lenBytes := length(ret);
        end;
        if ret[length(ret)] in [#0, '/'] then
          break;
      end;
      if tm < now then
        fim := true;
    until fim;
    // Retransmit the magnetic ink character reading result.
    if (length(ret) > 0) then
    begin
      result := ret;
      exit;
    end;
  finally
    FPosPrinter.ImprimirCMD(#27#99#48#0); // Roll paper enabled.
    FPosPrinter.controlePorta := cp;
  end;
  InternoChequeConcluido;

  finally
       CheckDesativar(not desligar);
  end;
end;

end.
