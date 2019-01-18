{******************************************************************************}
{ Projeto: Componente ACBrReinf                                                }
{  Biblioteca multiplataforma de componentes Delphi para envio de eventos do   }
{ Reinf                                                                        }

{ Direitos Autorais Reservados (c) 2017 Leivio Ramos de Fontenele              }
{                                                                              }

{ Colaboradores nesse arquivo:                                                 }

{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }


{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }

{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }

{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Leivio Ramos de Fontenele  -  leivio@yahoo.com.br                            }
{******************************************************************************}
{******************************************************************************
|* Historico
|*
|* 04/12/2017: Renato Rubinho
|*  - Implementados registros que faltavam e isoladas as respectivas classes
*******************************************************************************}

{$I ACBr.inc}

unit pcnReinfR1070;

interface

uses
  SysUtils, Classes,
  pcnConversao, pcnGerador, ACBrUtil,
  pcnCommonReinf, pcnConversaoReinf, pcnGeradorReinf;

type
  TR1070Collection = class;
  TR1070CollectionItem = class;
  TevtTabProcesso = class;

  {Classes espec�ficas deste evento}
  TinfoProcesso = class;
  TideProcesso = class;
  TinfoSuspCollection = class;
  TinfoSuspCollectionItem = class;
  TdadosProcJud = class;

  TR1070Collection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TR1070CollectionItem;
    procedure SetItem(Index: Integer; Value: TR1070CollectionItem);
  public
    function Add: TR1070CollectionItem;
    property Items[Index: Integer]: TR1070CollectionItem read GetItem write SetItem; default;
  end;

  TR1070CollectionItem = class(TCollectionItem)
  private
    FTipoEvento: TTipoEvento;
    FevtTabProcesso: TevtTabProcesso;
    procedure setevtTabProcesso(const Value: TevtTabProcesso);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  published
    property TipoEvento: TTipoEvento read FTipoEvento;
    property evtTabProcesso: TevtTabProcesso read FevtTabProcesso write setevtTabProcesso;
  end;

  TevtTabProcesso = class(TReinfEvento) //Classe do elemento principal do XML do evento!
  private
    FModoLancamento: TTipoOperacao;
    FIdeEvento: TIdeEvento;
    FideContri: TideContri;
    FinfoProcesso: TinfoProcesso;
    FACBrReinf: TObject;

    {Geradores espec�ficos desta classe}
    procedure GerarIdeProcesso(pEmp: TideProcesso);
    procedure GerarinfoSusp;
    procedure GerarDadosProcJud;
  public
    constructor Create(AACBrReinf: TObject); overload;
    destructor  Destroy; override;

    function GerarXML: Boolean; override;
    function LerArqIni(const AIniString: String): Boolean;

    property ModoLancamento: TTipoOperacao read FModoLancamento write FModoLancamento;
    property ideEvento: TIdeEvento read FIdeEvento write FIdeEvento;
    property ideContri: TideContri read FideContri write FideContri;
    property infoProcesso: TinfoProcesso read FinfoProcesso write FinfoProcesso;
  end;

  TinfoProcesso = class(TPersistent)
  private
    FideProcesso: TIdeProcesso;
    FNovaValidade: TidePeriodo;

    function getNovaValidade(): TidePeriodo;
  public
    constructor Create;
    destructor Destroy; override;

    function novaValidadeInst(): Boolean;

    property ideProcesso: TIdeProcesso read FideProcesso write FideProcesso;
    property novaValidade: TIdePeriodo read getNovaValidade write FnovaValidade;
  end;

  TideProcesso = class(TPersistent)
  private
    FTpProc: TtpProc;
    FNrProc: string;
    FIniValid: string;
    FFimValid: string;
    FindAutoria: TindAutoria;
    FinfoSusp: TinfoSuspCollection;
    FDadosProcJud: TDadosProcJud;
  public
    constructor Create;
    destructor Destroy; override;

    property tpProc: TtpProc read FTpProc write FTpProc;
    property nrProc: string read FNrProc write FNrProc;
    property IniValid: string read FIniValid write FIniValid;
    property FimValid: string read FFimValid write FFimValid;
    property indAutoria: TindAutoria read FindAutoria write FindAutoria;
    property infoSusp: TinfoSuspCollection read FinfoSusp write FinfoSusp;
    property DadosProcJud: TDadosProcJud read FDadosProcJud;
  end;

  TinfoSuspCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TinfoSuspCollectionItem;
    procedure SetItem(Index: Integer; Value: TinfoSuspCollectionItem);
  public
    constructor create(); reintroduce;
    function Add: TinfoSuspCollectionItem;
    property Items[Index: Integer]: TinfoSuspCollectionItem read GetItem write SetItem; default;
  end;

  TinfoSuspCollectionItem = class(TCollectionItem)
  private
    FcodSusp: string;
    FIndDeposito: TtpSimNao;
    FDTDecisao: TDateTime;
    FIndSusp: TIndSusp;
  public
    property codSusp: string read FcodSusp write FcodSusp;
    property indSusp: TIndSusp read FIndSusp write FIndSusp;
    property dtDecisao: TDateTime read FDTDecisao write FDTDecisao;
    property indDeposito: TtpSimNao read FIndDeposito write FIndDeposito;
  end;

  TdadosProcJud = class(TPersistent)
   private
    FUfVara: string;
    FCodMunic: integer;
    FIdVara: string;
  public
    property UfVara: string read FUfVara write FUfVara;
    property codMunic: integer read FCodMunic write FCodMunic;
    property idVara: string read FIdVara write FIdVara;
  end;

implementation

uses
  IniFiles,
  ACBrReinf, ACBrDFeUtil;

{ TR1070Collection }

function TR1070Collection.Add: TR1070CollectionItem;
begin
  Result := TR1070CollectionItem(inherited Add);
end;

function TR1070Collection.GetItem(Index: Integer): TR1070CollectionItem;
begin
  Result := TR1070CollectionItem(inherited GetItem(Index));
end;

procedure TR1070Collection.SetItem(Index: Integer; Value: TR1070CollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TR1070CollectionItem }

procedure TR1070CollectionItem.AfterConstruction;
begin
  inherited;
  FTipoEvento := teR1070;
  FevtTabProcesso := TevtTabProcesso.Create(Collection.Owner);
end;

procedure TR1070CollectionItem.BeforeDestruction;
begin
  inherited;
  FevtTabProcesso.Free;
end;

procedure TR1070CollectionItem.setevtTabProcesso(const Value: TevtTabProcesso);
begin
  FevtTabProcesso.Assign(Value);
end;

{ TinfoProcesso }

constructor TinfoProcesso.Create;
begin
  inherited;

  FideProcesso  := TIdeProcesso.Create;
  FNovaValidade := nil;
end;

destructor TinfoProcesso.Destroy;
begin
  FideProcesso.Free;
  FreeAndNil(FNovaValidade);

  inherited;
end;

function TinfoProcesso.getNovaValidade: TidePeriodo;
begin
  if Not(Assigned(FNovaValidade)) then
    FNovaValidade := TIdePeriodo.Create;
  Result := FNovaValidade;
end;

function TinfoProcesso.novaValidadeInst: Boolean;
begin
  Result := Assigned(FNovaValidade);
end;

{ TideProcesso }

constructor TideProcesso.Create;
begin
  FinfoSusp     := TinfoSuspCollection.Create;
  FDadosProcJud := TdadosProcJud.Create;
end;

destructor TideProcesso.Destroy;
begin
  FinfoSusp.Free;
  FDadosProcJud.Free;

  inherited;
end;

{ TinfoSuspCollection }

function TinfoSuspCollection.Add: TinfoSuspCollectionItem;
begin
  Result := TinfoSuspCollectionItem(inherited add());
//  Result.Create;
end;

constructor TinfoSuspCollection.create;
begin
  Inherited create(TinfoSuspCollectionItem);
end;

function TinfoSuspCollection.GetItem(
  Index: Integer): TinfoSuspCollectionItem;
begin
  Result := TinfoSuspCollectionItem(inherited GetItem(Index));
end;

procedure TinfoSuspCollection.SetItem(Index: Integer;
  Value: TinfoSuspCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TevtTabProcesso }

constructor TevtTabProcesso.Create(AACBrReinf: TObject);
begin
  inherited;

  FACBrReinf := AACBrReinf;

  FideContri    := TideContri.create;
  FIdeEvento    := TIdeEvento.create;
  FinfoProcesso := TinfoProcesso.Create;
end;

destructor TevtTabProcesso.Destroy;
begin
  FideContri.Free;
  FIdeEvento.Free;
  FinfoProcesso.Free;

  inherited;
end;

procedure TevtTabProcesso.GerarIdeProcesso(pEmp: TideProcesso);
begin
  Gerador.wGrupo('ideProcesso');

  Gerador.wCampo(tcStr, '', 'tpProc',   1,  1, 1, TpProcToStr(pEmp.tpProc));
  Gerador.wCampo(tcStr, '', 'nrProc',   1, 21, 1, pEmp.nrProc);
  Gerador.wCampo(tcStr, '', 'iniValid', 7,  7, 1, pEmp.IniValid);
  Gerador.wCampo(tcStr, '', 'fimValid', 7,  7, 0, pEmp.FimValid);

  if (Self.ModoLancamento <> toExclusao) then
  begin
    Gerador.wCampo(tcStr, '', 'indAutoria', 1, 21, 1, indAutoriaToStr(pEmp.indAutoria));

    GerarinfoSusp;

    if pEmp.tpProc = tpJudicial then
      GerarDadosProcJud;
  end;

  Gerador.wGrupo('/ideProcesso');
end;

procedure TevtTabProcesso.GerarinfoSusp;
var
  InfoSusp: TinfoSuspCollectionItem;
  i: Integer;
begin
  for i := 0 to infoProcesso.ideProcesso.infoSusp.Count - 1 do
  begin
    InfoSusp := FinfoProcesso.IdeProcesso.infoSusp.Items[i];

    Gerador.wGrupo('infoSusp');

    if StrToInt64Def(InfoSusp.codSusp, -1) > 0 then
      Gerador.wCampo(tcStr, '', 'codSusp', 14, 14, 0, Poem_Zeros(InfoSusp.codSusp, 14));

    Gerador.wCampo(tcStr, '', 'indSusp',      2,  2, 1, IndSuspToStr(InfoSusp.indSusp));
    Gerador.wCampo(tcDat, '', 'dtDecisao',   10, 10, 1, InfoSusp.dtDecisao);
    Gerador.wCampo(tcStr, '', 'indDeposito',  1,  1, 1, SimNaoToStr(InfoSusp.indDeposito));

    Gerador.wGrupo('/infoSusp');
  end;

  if infoProcesso.ideProcesso.infoSusp.Count > 50 then
    Gerador.wAlerta('', 'infoSusp', 'Lista de Informa��es de Suspens�o', ERR_MSG_MAIOR_MAXIMO + '50');
end;

procedure TevtTabProcesso.GerarDadosProcJud;
begin
  Gerador.wGrupo('dadosProcJud');

  Gerador.wCampo(tcStr, '', 'ufVara',   2, 2, 1, FinfoProcesso.IdeProcesso.DadosProcJud.UfVara);
  Gerador.wCampo(tcInt, '', 'codMunic', 7, 7, 1, FinfoProcesso.IdeProcesso.DadosProcJud.codMunic);

  if Self.VersaoDF >= v1_04_00 then
    Gerador.wCampo(tcStr, '', 'idVara',   4, 4, 1, Poem_Zeros(FinfoProcesso.IdeProcesso.DadosProcJud.idVara, 4))
  else
    Gerador.wCampo(tcStr, '', 'idVara',   2, 2, 1, Poem_Zeros(FinfoProcesso.IdeProcesso.DadosProcJud.idVara, 2));

  Gerador.wGrupo('/dadosProcJud');
end;

function TevtTabProcesso.GerarXML: Boolean;
begin
  try
    Self.VersaoDF := TACBrReinf(FACBrReinf).Configuracoes.Geral.VersaoDF;

    Self.Id := GerarChaveReinf(now, self.ideContri.NrInsc, self.Sequencial);

    GerarCabecalho('evtTabProcesso');
    Gerador.wGrupo('evtTabProcesso id="' + Self.Id + '"');

    GerarIdeEvento(Self.IdeEvento);
    GerarideContri(Self.ideContri);

    Gerador.wGrupo('infoProcesso');

    GerarModoAbertura(Self.ModoLancamento);
    GerarIdeProcesso(Self.infoProcesso.ideProcesso);

    if (ModoLancamento = toAlteracao) and (infoProcesso.novaValidadeInst()) then
      GerarIdePeriodo(infoProcesso.novaValidade, 'novaValidade');

    GerarModoFechamento(Self.ModoLancamento);

    Gerador.wGrupo('/infoProcesso');
    Gerador.wGrupo('/evtTabProcesso');

    GerarRodape;

    XML := Assinar(Gerador.ArquivoFormatoXML, 'evtTabProcesso');

    Validar(schevtTabProcesso);
  except on e:exception do
    raise Exception.Create(e.Message);
  end;

  Result := (Gerador.ArquivoFormatoXML <> '');
end;

function TevtTabProcesso.LerArqIni(const AIniString: String): Boolean;
var
  INIRec: TMemIniFile;
  Ok: Boolean;
  sSecao, sFim: String;
  I: Integer;
begin
  Result := False;

  INIRec := TMemIniFile.Create('');
  try
    LerIniArquivoOuString(AIniString, INIRec);

    with Self do
    begin
      sSecao := 'evtTabProcesso';
      Id             := INIRec.ReadString(sSecao, 'Id', '');
      Sequencial     := INIRec.ReadInteger(sSecao, 'Sequencial', 0);
      ModoLancamento := StrToTipoOperacao(Ok, INIRec.ReadString(sSecao, 'ModoLancamento', 'inclusao'));

      sSecao := 'ideEvento';
      ideEvento.TpAmb   := StrTotpAmbReinf(Ok, INIRec.ReadString(sSecao, 'tpAmb', '1'));
      ideEvento.ProcEmi := StrToProcEmiReinf(Ok, INIRec.ReadString(sSecao, 'procEmi', '1'));
      ideEvento.VerProc := INIRec.ReadString(sSecao, 'verProc', EmptyStr);

      sSecao := 'ideContri';
      ideContri.OrgaoPublico := (TACBrReinf(FACBrReinf).Configuracoes.Geral.TipoContribuinte = tcOrgaoPublico);
      ideContri.TpInsc       := StrToTpInscricao(Ok, INIRec.ReadString(sSecao, 'tpInsc', '1'));
      ideContri.NrInsc       := INIRec.ReadString(sSecao, 'nrInsc', EmptyStr);

      sSecao := 'ideProcesso';
      infoProcesso.ideProcesso.tpProc     := StrToTpProc(Ok, INIRec.ReadString(sSecao, 'tpProc', '1'));
      infoProcesso.ideProcesso.nrProc     := INIRec.ReadString(sSecao, 'nrProc', EmptyStr);
      infoProcesso.ideProcesso.IniValid   := INIRec.ReadString(sSecao, 'iniValid', EmptyStr);
      infoProcesso.ideProcesso.FimValid   := INIRec.ReadString(sSecao, 'fimValid', EmptyStr);
      infoProcesso.ideProcesso.indAutoria := StrToindAutoria(Ok, INIRec.ReadString(sSecao, 'indAutoria', '1'));

      if (ModoLancamento <> toExclusao) then
      begin
        I := 1;
        while true do
        begin
          // de 01 at� 50
          sSecao := 'infoSusp' + IntToStrZero(I, 2);
          sFim   := INIRec.ReadString(sSecao, 'codSusp', 'FIM');

          if (sFim = 'FIM') or (Length(sFim) <= 0) then
            break;

          with infoProcesso.ideProcesso.infoSusp.Add do
          begin
            codSusp     := sFim;
            indSusp     := StrToIndSusp(Ok, INIRec.ReadString(sSecao, 'indSusp', '01'));
            dtDecisao   := StringToDateTime(INIRec.ReadString(sSecao, 'dtDecisao', '0'));
            indDeposito := StrToSimNao(Ok, INIRec.ReadString(sSecao, 'indDeposito', 'S'));
          end;

          Inc(I);
        end;

        sSecao := 'dadosProcJud';
        if INIRec.ReadString(sSecao, 'UfVara', '') <> ''then
        begin
          infoProcesso.ideProcesso.dadosProcJud.UfVara   := INIRec.ReadString(sSecao, 'UfVara', 'SP');
          infoProcesso.ideProcesso.dadosProcJud.codMunic := INIRec.ReadInteger(sSecao, 'codMunic', 0);
          infoProcesso.ideProcesso.dadosProcJud.idVara   := INIRec.ReadString(sSecao, 'idVara', '0');
        end;

        if ModoLancamento = toAlteracao then
        begin
          sSecao := 'novaValidade';
          infoProcesso.novaValidade.IniValid := INIRec.ReadString(sSecao, 'iniValid', EmptyStr);
          infoProcesso.novaValidade.FimValid := INIRec.ReadString(sSecao, 'fimValid', EmptyStr);
        end;
      end;
    end;

    GerarXML;

    Result := True;
  finally
     INIRec.Free;
  end;
end;

end.
