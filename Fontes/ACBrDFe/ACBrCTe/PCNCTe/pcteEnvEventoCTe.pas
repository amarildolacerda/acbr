////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//              PCN - Projeto Cooperar CTe                                    //
//                                                                            //
//   Descri��o: Classes para gera��o/leitura dos arquivos xml da CTe          //
//                                                                            //
//        site: www.projetocooperar.org/cte                                   //
//       email: projetocooperar@zipmail.com.br                                //
//       forum: http://br.groups.yahoo.com/group/projeto_cooperar_cte/        //
//     projeto: http://code.google.com/p/projetocooperar/                     //
//         svn: http://projetocooperar.googlecode.com/svn/trunk/              //
//                                                                            //
// Coordena��o: (c) 2009 - Paulo Casagrande                                   //
//                                                                            //
//      Equipe: Vide o arquivo leiame.txt na pasta raiz do projeto            //
//                                                                            //
//      Vers�o: Vide o arquivo leiame.txt na pasta raiz do projeto            //
//                                                                            //
//     Licen�a: GNU Lesser General Public License (GNU LGPL)                  //
//                                                                            //
//              - Este programa � software livre; voc� pode redistribu�-lo    //
//              e/ou modific�-lo sob os termos da Licen�a P�blica Geral GNU,  //
//              conforme publicada pela Free Software Foundation; tanto a     //
//              vers�o 2 da Licen�a como (a seu crit�rio) qualquer vers�o     //
//              mais nova.                                                    //
//                                                                            //
//              - Este programa � distribu�do na expectativa de ser �til,     //
//              mas SEM QUALQUER GARANTIA; sem mesmo a garantia impl�cita de  //
//              COMERCIALIZA��O ou de ADEQUA��O A QUALQUER PROP�SITO EM       //
//              PARTICULAR. Consulte a Licen�a P�blica Geral GNU para obter   //
//              mais detalhes. Voc� deve ter recebido uma c�pia da Licen�a    //
//              P�blica Geral GNU junto com este programa; se n�o, escreva    //
//              para a Free Software Foundation, Inc., 59 Temple Place,       //
//              Suite 330, Boston, MA - 02111-1307, USA ou consulte a         //
//              licen�a oficial em http://www.gnu.org/licenses/gpl.txt        //
//                                                                            //
//    Nota (1): - Esta  licen�a  n�o  concede  o  direito  de  uso  do nome   //
//              "PCN  -  Projeto  Cooperar  NFe", n�o  podendo o mesmo ser    //
//              utilizado sem previa autoriza��o.                             //
//                                                                            //
//    Nota (2): - O uso integral (ou parcial) das units do projeto esta       //
//              condicionado a manuten��o deste cabe�alho junto ao c�digo     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{$I ACBr.inc}

unit pcteEnvEventoCTe;

interface

uses
  SysUtils, Classes,
//{$IFNDEF VER130}
//  Variants,
//{$ENDIF}
  pcnConversao, pcnGerador, pcnConsts, //pcnLeitor,
  pcteConversaoCTe, pcteEventoCTe, pcteConsts, pcnSignature;

type
  TInfEventoCollection     = class;
  TInfEventoCollectionItem = class;
  TEventoCTe               = class;
  EventoCTeException       = class(Exception);

  TInfEventoCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TInfEventoCollectionItem;
    procedure SetItem(Index: Integer; Value: TInfEventoCollectionItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TInfEventoCollectionItem;
    property Items[Index: Integer]: TInfEventoCollectionItem read GetItem write SetItem; default;
  end;

  TInfEventoCollectionItem = class(TCollectionItem)
  private
    FInfEvento: TInfEvento;
    FRetInfEvento: TRetInfEvento;
    Fsignature: Tsignature;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  published
    property InfEvento: TInfEvento       read FInfEvento    write FInfEvento;
    property signature: Tsignature       read Fsignature    write Fsignature;
    property RetInfEvento: TRetInfEvento read FRetInfEvento write FRetInfEvento;
  end;

  TGeradorOpcoes = class(TPersistent)
  private
    FAjustarTagNro: Boolean;
    FNormatizarMunicipios: Boolean;
    FGerarTagAssinatura: TpcnTagAssinatura;
    FPathArquivoMunicipios: String;
    FValidarInscricoes: Boolean;
    FValidarListaServicos: Boolean;
  published
    property AjustarTagNro: Boolean                read FAjustarTagNro         write FAjustarTagNro;
    property NormatizarMunicipios: Boolean         read FNormatizarMunicipios  write FNormatizarMunicipios;
    property GerarTagAssinatura: TpcnTagAssinatura read FGerarTagAssinatura    write FGerarTagAssinatura;
    property PathArquivoMunicipios: String         read FPathArquivoMunicipios write FPathArquivoMunicipios;
    property ValidarInscricoes: Boolean            read FValidarInscricoes     write FValidarInscricoes;
    property ValidarListaServicos: Boolean         read FValidarListaServicos  write FValidarListaServicos;
  end;

  { TEventoCTe }

  TEventoCTe = class(TPersistent)
  private
    FGerador: TGerador;
    FOpcoes: TGeradorOpcoes;
    FidLote: Integer;
    FEvento: TInfEventoCollection;
    FVersao: String;
    FXML: AnsiString;
    FVersaoDF: TVersaoCTe;

    procedure SetEvento(const Value: TInfEventoCollection);
  public
    constructor Create;
    destructor Destroy; override;
    function GerarXML: boolean;
    function LerXML(CaminhoArquivo: string): boolean;
    function LerXMLFromString(const AXML: String): boolean;
    function ObterNomeArquivo(tpEvento: TpcnTpEvento): string;
    function LerFromIni(const AIniString: String; CCe: Boolean = True): Boolean;
  published
    property Gerador: TGerador            read FGerador  write FGerador;
    property Opcoes: TGeradorOpcoes       read FOpcoes   write FOpcoes;
    property idLote: Integer              read FidLote   write FidLote;
    property Evento: TInfEventoCollection read FEvento   write SetEvento;
    property Versao: String               read FVersao   write FVersao;
    property XML: AnsiString              read FXML      write FXML;
    property VersaoDF: TVersaoCTe         read FVersaoDF write FVersaoDF;
  end;

implementation

uses
  IniFiles,
  pcnAuxiliar, pcteRetEnvEventoCTe,
  ACBrUtil, ACBrDFeUtil;

{ TEventoCTe }

constructor TEventoCTe.Create;
begin
  FGerador := TGerador.Create;
  FOpcoes  := TGeradorOpcoes.Create;
  FOpcoes.FAjustarTagNro := True;
  FOpcoes.FNormatizarMunicipios := False;
  FOpcoes.FGerarTagAssinatura := taSomenteSeAssinada;
  FOpcoes.FValidarInscricoes := False;
  FOpcoes.FValidarListaServicos := False;
  FEvento  := TInfEventoCollection.Create(Self);
end;

destructor TEventoCTe.Destroy;
begin
  FGerador.Free;
  FOpcoes.Free;
  FEvento.Free;
  inherited;
end;

function TEventoCTe.GerarXML: boolean;
var
  sDoc: String;
  i, j: Integer;
  Ok: Boolean;
begin
  VersaoDF := StrToVersaoCTe(Ok, Versao);

  Gerador.ArquivoFormatoXML := '';
  Gerador.wGrupo('eventoCTe ' + NAME_SPACE_CTE + ' versao="' + Versao + '"');

  Evento.Items[0].InfEvento.Id := 'ID'+ Evento.Items[0].InfEvento.TipoEvento +
                                        OnlyNumber(Evento.Items[0].InfEvento.chCTe) +
                                        Format('%.2d', [Evento.Items[0].InfEvento.nSeqEvento]);

  Gerador.wGrupo('infEvento Id="' + Evento.Items[0].InfEvento.Id + '"');
  if Length(Evento.Items[0].InfEvento.Id) < 54
   then Gerador.wAlerta('EP04', 'ID', '', 'ID de Evento inv�lido');

  Gerador.wCampo(tcInt, 'EP05', 'cOrgao', 1, 2, 1, Evento.Items[0].InfEvento.cOrgao);
  Gerador.wCampo(tcStr, 'EP06', 'tpAmb ', 1, 1, 1, TpAmbToStr(Evento.Items[0].InfEvento.tpAmb), DSC_TPAMB);

  sDoc := OnlyNumber( Evento.Items[0].InfEvento.CNPJ );

  case Length( sDoc ) of
    14 : begin
          Gerador.wCampo(tcStr, 'EP07', 'CNPJ', 14, 14, 1, sDoc , DSC_CNPJ);
          if not ValidarCNPJ( sDoc ) then Gerador.wAlerta('HP10', 'CNPJ', DSC_CNPJ, ERR_MSG_INVALIDO);
         end;
    11 : begin
          Gerador.wCampo(tcStr, 'EP07', 'CPF ', 11, 11, 1, sDoc, DSC_CPF);
          if not ValidarCPF( sDoc ) then Gerador.wAlerta('HP11', 'CPF', DSC_CPF, ERR_MSG_INVALIDO);
         end;
  end;

  Gerador.wCampo(tcStr, 'EP08', 'chCTe', 44, 44, 1, Evento.Items[0].InfEvento.chCTe, DSC_CHAVE);

  if not ValidarChave(Evento.Items[0].InfEvento.chCTe)
   then Gerador.wAlerta('EP08', 'chCTe', '', 'Chave de CTe inv�lida');

  if VersaoDF >= ve300 then
    Gerador.wCampo(tcStr, 'EP09', 'dhEvento  ', 01, 27, 1, DateTimeTodh(Evento.Items[0].InfEvento.dhEvento) +
                                                             GetUTC(CodigoParaUF(Evento.Items[0].InfEvento.cOrgao),
                                                             Evento.Items[0].InfEvento.dhEvento), DSC_DEMI)
  else
    Gerador.wCampo(tcStr, 'EP09', 'dhEvento  ', 01, 27, 1, FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Evento.Items[0].InfEvento.dhEvento));
		
  Gerador.wCampo(tcInt, 'EP10', 'tpEvento  ', 06, 06, 1, Evento.Items[0].InfEvento.TipoEvento);
  Gerador.wCampo(tcInt, 'EP11', 'nSeqEvento', 01, 02, 1, Evento.Items[0].InfEvento.nSeqEvento);

  Gerador.wGrupo('detEvento versaoEvento="' + Versao + '"');
  case Evento.Items[0].InfEvento.tpEvento of
   teCCe:
     begin
       Gerador.wGrupo('evCCeCTe');
       Gerador.wCampo(tcStr, 'EP02', 'descEvento', 17, 17, 1, Evento.Items[0].InfEvento.DescEvento);

       for i := 0 to Evento.Items[0].FInfEvento.detEvento.infCorrecao.Count - 1 do
        begin
         Gerador.wGrupo('infCorrecao');
         Gerador.wCampo(tcStr, 'EP04', 'grupoAlterado  ', 01, 020, 1, Evento.Items[0].InfEvento.detEvento.infCorrecao.Items[i].grupoAlterado);
         Gerador.wCampo(tcStr, 'EP05', 'campoAlterado  ', 01, 020, 1, Evento.Items[0].InfEvento.detEvento.infCorrecao.Items[i].campoAlterado);
         Gerador.wCampo(tcStr, 'EP06', 'valorAlterado  ', 01, 500, 1, Evento.Items[0].InfEvento.detEvento.infCorrecao.Items[i].valorAlterado);
         Gerador.wCampo(tcInt, 'EP07', 'nroItemAlterado', 02, 002, 0, Evento.Items[0].InfEvento.detEvento.infCorrecao.Items[i].nroItemAlterado);
         Gerador.wGrupo('/infCorrecao');
        end;

       Gerador.wCampo(tcStr, 'EP08', 'xCondUso', 01, 5000, 1, Evento.Items[0].InfEvento.detEvento.xCondUso);
       Gerador.wGrupo('/evCCeCTe');
     end;
   teCancelamento:
     begin
       Gerador.wGrupo('evCancCTe');
       Gerador.wCampo(tcStr, 'EP02', 'descEvento', 12, 012, 1, Evento.Items[0].InfEvento.DescEvento);
       Gerador.wCampo(tcStr, 'EP03', 'nProt     ', 15, 015, 1, Evento.Items[0].InfEvento.detEvento.nProt);
       Gerador.wCampo(tcStr, 'EP04', 'xJust     ', 15, 255, 1, Evento.Items[0].InfEvento.detEvento.xJust);
       Gerador.wGrupo('/evCancCTe');
     end;
   teEPEC:
     begin
       Gerador.wGrupo('evEPECCTe');
       Gerador.wCampo(tcStr, 'EP02', 'descEvento', 04, 004, 1, Evento.Items[0].InfEvento.DescEvento);
       Gerador.wCampo(tcStr, 'EP04', 'xJust     ', 15, 255, 1, Evento.Items[0].InfEvento.detEvento.xJust);
       Gerador.wCampo(tcDe2, 'EP05', 'vICMS     ', 01, 015, 1, Evento.Items[0].InfEvento.detEvento.vICMS, DSC_VICMS);
       Gerador.wCampo(tcDe2, 'EP06', 'vTPrest   ', 01, 015, 1, Evento.Items[0].InfEvento.detEvento.vTPrest, DSC_VTPREST);
       Gerador.wCampo(tcDe2, 'EP07', 'vCarga    ', 01, 015, 1, Evento.Items[0].InfEvento.detEvento.vCarga, DSC_VTMERC);

       if VersaoDF >= ve300 then
         Gerador.wGrupo('toma4')
       else
         Gerador.wGrupo('toma04');

       Gerador.wCampo(tcStr, 'EP09', 'toma', 01, 01, 1, TpTomadorToStr(Evento.Items[0].InfEvento.detEvento.toma), DSC_TOMA);
       Gerador.wCampo(tcStr, 'EP10', 'UF  ', 02, 02, 1, Evento.Items[0].InfEvento.detEvento.UF, DSC_UF);
       if not ValidarUF(Evento.Items[0].InfEvento.detEvento.UF) then
         Gerador.wAlerta('EP10', 'UF', DSC_UF, ERR_MSG_INVALIDO);
       Gerador.wCampoCNPJCPF('EP11', 'EP12', Evento.Items[0].InfEvento.detEvento.CNPJCPF);

       if Evento.Items[0].InfEvento.detEvento.IE <> ''
         then begin
          if Trim(Evento.Items[0].InfEvento.detEvento.IE) = 'ISENTO' then
            Gerador.wCampo(tcStr, 'EP13', 'IE  ', 00, 14, 0, Evento.Items[0].InfEvento.detEvento.IE, DSC_IE)
          else
            Gerador.wCampo(tcStr, 'EP13', 'IE  ', 00, 14, 0, OnlyNumber(Evento.Items[0].InfEvento.detEvento.IE), DSC_IE);

          if not ValidarIE(Evento.Items[0].InfEvento.detEvento.IE, Evento.Items[0].InfEvento.detEvento.UF) then
            Gerador.wAlerta('EP13', 'IE', DSC_IE, ERR_MSG_INVALIDO);
         end;

       if VersaoDF >= ve300 then
         Gerador.wGrupo('/toma4')
       else
         Gerador.wGrupo('/toma04');

       Gerador.wCampo(tcStr, 'EP14', 'modal   ', 02, 02, 1, TpModalToStr(Evento.Items[0].InfEvento.detEvento.modal), DSC_MODAL);
       Gerador.wCampo(tcStr, 'EP15', 'UFIni   ', 02, 02, 1, Evento.Items[0].InfEvento.detEvento.UFIni, DSC_UF);
       if not ValidarUF(Evento.Items[0].InfEvento.detEvento.UFIni) then
         Gerador.wAlerta('EP15', 'UFIni', DSC_UF, ERR_MSG_INVALIDO);
       Gerador.wCampo(tcStr, 'EP16', 'UFFim   ', 02, 02, 1, Evento.Items[0].InfEvento.detEvento.UFFim, DSC_UF);
       if not ValidarUF(Evento.Items[0].InfEvento.detEvento.UFFim) then
         Gerador.wAlerta('EP16', 'UFFim', DSC_UF, ERR_MSG_INVALIDO);

       if VersaoDF >= ve300 then
       begin
//         Gerador.wCampo(tcStr, 'EP17', 'tpCTe', 01, 01, 1, tpCTePagToStr(Evento.Items[0].InfEvento.detEvento.tpCTe), DSC_TPCTE);
         // Segundo o Manual p�gina 104 devemos informar o valor "0" para tpCTe
         Gerador.wCampo(tcStr, 'EP17', 'tpCTe', 01, 01, 1, '0', DSC_TPCTE);
         Gerador.wCampo(tcStr, 'EP18', 'dhEmi', 25, 25, 1, DateTimeTodh(Evento.Items[0].InfEvento.detEvento.dhEmi) +
                                  GetUTC(Evento.Items[0].InfEvento.detEvento.UF,
                                  Evento.Items[0].InfEvento.detEvento.dhEmi), DSC_DEMI);
       end;

       Gerador.wGrupo('/evEPECCTe');
     end;
   teMultiModal:
     begin
       Gerador.wGrupo('evRegMultimodal');
       Gerador.wCampo(tcStr, 'EP02', 'descEvento', 23, 0023, 1, Evento.Items[0].InfEvento.DescEvento);
       Gerador.wCampo(tcStr, 'EP03', 'xRegistro ', 15, 1000, 1, Evento.Items[0].InfEvento.detEvento.xRegistro);
       Gerador.wCampo(tcStr, 'EP04', 'nDoc      ', 01, 0043, 0, Evento.Items[0].InfEvento.detEvento.nDoc);
       Gerador.wGrupo('/evRegMultimodal');
     end;
   tePrestDesacordo:
     begin
       Gerador.wGrupo('evPrestDesacordo');
       Gerador.wCampo(tcStr, 'EP02', 'descEvento      ', 33, 033, 1, Evento.Items[0].InfEvento.DescEvento);
       Gerador.wCampo(tcStr, 'EP03', 'indDesacordoOper', 01, 001, 1, '1');
       Gerador.wCampo(tcStr, 'EP04', 'xObs            ', 15, 255, 1, Evento.Items[0].InfEvento.detEvento.xOBS);
       Gerador.wGrupo('/evPrestDesacordo');
     end;
   teGTV:
     begin
       Gerador.wGrupo('evGTV');
       Gerador.wCampo(tcStr, 'EP02', 'descEvento      ', 33, 033, 1, Evento.Items[0].InfEvento.DescEvento);

       for i := 0 to Evento.Items[0].FInfEvento.detEvento.infGTV.Count - 1 do
       begin
         Gerador.wGrupo('infGTV');
         Gerador.wCampo(tcStr, 'EP04', 'nDoc    ', 20, 20, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].nDoc);
         Gerador.wCampo(tcStr, 'EP05', 'id      ', 20, 20, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].id);
         Gerador.wCampo(tcStr, 'EP06', 'serie   ', 03, 03, 0, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].serie);
         Gerador.wCampo(tcStr, 'EP07', 'subserie', 03, 03, 0, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].subserie);
         Gerador.wCampo(tcDat, 'EP08', 'dEmi    ', 10, 10, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dEmi);
         Gerador.wCampo(tcInt, 'EP09', 'nDV     ', 01, 01, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].nDV);
         Gerador.wCampo(tcDe4, 'EP10', 'qCarga  ', 01, 15, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].qCarga);

         for j := 0 to Evento.Items[0].FInfEvento.detEvento.infGTV.Items[i].infEspecie.Count - 1 do
         begin
           Gerador.wGrupo('infEspecie');
           Gerador.wCampo(tcStr, 'EP12', 'tpEspecie', 01, 01, 1, TEspecieToStr(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].infEspecie.Items[j].tpEspecie));
           Gerador.wCampo(tcDe2, 'EP13', 'vEspecie ', 01, 15, 0, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].infEspecie.Items[j].vEspecie);
           Gerador.wGrupo('/infEspecie');
         end;

         Gerador.wGrupo('rem');
         Gerador.wCampoCNPJCPF('EP15', 'EP16', Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.CNPJCPF);

         if trim(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.IE) <> '' then
         begin
           if Trim(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.IE) = 'ISENTO' then
             Gerador.wCampo(tcStr, 'EP17', 'IE', 00, 14, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.IE, DSC_IE)
           else
             Gerador.wCampo(tcStr, 'EP17', 'IE', 00, 14, 1, OnlyNumber(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.IE), DSC_IE);

           if (FOpcoes.ValidarInscricoes) then
             if not ValidarIE(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.IE, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.UF) then
               Gerador.wAlerta('EP17', 'IE', DSC_IE, ERR_MSG_INVALIDO);
         end;

         Gerador.wCampo(tcStr, 'EP18', 'UF   ', 02, 02, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.UF, DSC_UF);
         Gerador.wCampo(tcStr, 'EP19', 'xNome', 02, 60, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].rem.xNome, DSC_XNOME);
         Gerador.wGrupo('/rem');

         Gerador.wGrupo('dest');
         Gerador.wCampoCNPJCPF('EP21', 'EP22', Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.CNPJCPF);

         if trim(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.IE) <> '' then
         begin
           if Trim(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.IE) = 'ISENTO' then
             Gerador.wCampo(tcStr, 'EP23', 'IE', 00, 14, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.IE, DSC_IE)
           else
             Gerador.wCampo(tcStr, 'EP23', 'IE', 00, 14, 1, OnlyNumber(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.IE), DSC_IE);

           if (FOpcoes.ValidarInscricoes) then
             if not ValidarIE(Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.IE, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.UF) then
               Gerador.wAlerta('EP23', 'IE', DSC_IE, ERR_MSG_INVALIDO);
         end;

         Gerador.wCampo(tcStr, 'EP24', 'UF   ', 02, 02, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.UF, DSC_UF);
         Gerador.wCampo(tcStr, 'EP25', 'xNome', 02, 60, 1, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].dest.xNome, DSC_XNOME);
         Gerador.wGrupo('/dest');

         Gerador.wCampo(tcStr, 'EP26', 'placa', 07, 07, 0, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].placa, DSC_PLACA);
         Gerador.wCampo(tcStr, 'EP27', 'UF   ', 02, 02, 0, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].UF, DSC_UF);
         Gerador.wCampo(tcStr, 'EP28', 'RNTRC', 06, 08, 0, Evento.Items[0].InfEvento.detEvento.infGTV.Items[i].RNTRC, DSC_RNTRC);

         Gerador.wGrupo('/infGTV');
       end;

       Gerador.wGrupo('/evGTV');
     end;
  end;
  Gerador.wGrupo('/detEvento');
  Gerador.wGrupo('/infEvento');

  if Evento.Items[0].signature.URI <> '' then
  begin
    Evento.Items[0].signature.Gerador.Opcoes.IdentarXML := Gerador.Opcoes.IdentarXML;
    Evento.Items[0].signature.GerarXML;
    Gerador.ArquivoFormatoXML := Gerador.ArquivoFormatoXML + Evento.Items[0].signature.Gerador.ArquivoFormatoXML;
  end;

  Gerador.wGrupo('/eventoCTe');

  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

procedure TEventoCTe.SetEvento(const Value: TInfEventoCollection);
begin
  FEvento.Assign(Value);
end;

function TEventoCTe.LerXML(CaminhoArquivo: String): boolean;
var
  ArqEvento: TStringList;
begin
  ArqEvento := TStringList.Create;
  try
     ArqEvento.LoadFromFile(CaminhoArquivo);
     Result := LerXMLFromString(ArqEvento.Text);
  finally
     ArqEvento.Free;
  end;
end;

function TEventoCTe.LerXMLFromString(const AXML: String): boolean;
var
  RetEventoCTe: TRetEventoCTe;
  i, j: Integer;
begin
  FXML := AXML;
  RetEventoCTe := TRetEventoCTe.Create;
  try
     RetEventoCTe.Leitor.Arquivo := AXML;
     Result := RetEventoCTe.LerXml;
     with FEvento.Add do
      begin
        infEvento.Id         := RetEventoCTe.InfEvento.Id;
        InfEvento.cOrgao     := RetEventoCTe.InfEvento.cOrgao;
        infEvento.tpAmb      := RetEventoCTe.InfEvento.tpAmb;
        infEvento.CNPJ       := RetEventoCTe.InfEvento.CNPJ;
        infEvento.chCTe      := RetEventoCTe.InfEvento.chCTe;
        infEvento.dhEvento   := RetEventoCTe.InfEvento.dhEvento;
        infEvento.tpEvento   := RetEventoCTe.InfEvento.tpEvento;
        infEvento.nSeqEvento := RetEventoCTe.InfEvento.nSeqEvento;

        infEvento.VersaoEvento         := RetEventoCTe.InfEvento.VersaoEvento;
        infEvento.detEvento.descEvento := RetEventoCTe.InfEvento.detEvento.descEvento;
        infEvento.detEvento.nProt      := RetEventoCTe.InfEvento.detEvento.nProt;
        infEvento.detEvento.xJust      := RetEventoCTe.InfEvento.DetEvento.xJust;
        infEvento.detEvento.vICMS      := RetEventoCTe.InfEvento.DetEvento.vICMS;
        infEvento.detEvento.vTPrest    := RetEventoCTe.InfEvento.DetEvento.vTPrest;
        infEvento.detEvento.vCarga     := RetEventoCTe.InfEvento.DetEvento.vCarga;
        infEvento.detEvento.toma       := RetEventoCTe.InfEvento.DetEvento.toma;
        infEvento.detEvento.UF         := RetEventoCTe.InfEvento.DetEvento.UF;
        infEvento.detEvento.CNPJCPF    := RetEventoCTe.InfEvento.DetEvento.CNPJCPF;
        infEvento.detEvento.IE         := RetEventoCTe.InfEvento.DetEvento.IE;
        infEvento.detEvento.modal      := RetEventoCTe.InfEvento.DetEvento.modal;
        infEvento.detEvento.UFIni      := RetEventoCTe.InfEvento.DetEvento.UFIni;
        infEvento.detEvento.UFFim      := RetEventoCTe.InfEvento.DetEvento.UFFim;
        infEvento.detEvento.xCondUso   := RetEventoCTe.InfEvento.DetEvento.xCondUso;
        infEvento.detEvento.xOBS       := RetEventoCTe.InfEvento.detEvento.xOBS;

        signature.URI             := RetEventoCTe.signature.URI;
        signature.DigestValue     := RetEventoCTe.signature.DigestValue;
        signature.SignatureValue  := RetEventoCTe.signature.SignatureValue;
        signature.X509Certificate := RetEventoCTe.signature.X509Certificate;

        for i := 0 to RetEventoCTe.InfEvento.detEvento.infCorrecao.Count -1 do
        begin
          infEvento.detEvento.infCorrecao.Add;
          infEvento.detEvento.infCorrecao[i].grupoAlterado   := RetEventoCTe.InfEvento.detEvento.infCorrecao[i].grupoAlterado;
          infEvento.detEvento.infCorrecao[i].campoAlterado   := RetEventoCTe.InfEvento.detEvento.infCorrecao[i].campoAlterado;
          infEvento.detEvento.infCorrecao[i].valorAlterado   := RetEventoCTe.InfEvento.detEvento.infCorrecao[i].valorAlterado;
          infEvento.detEvento.infCorrecao[i].nroItemAlterado := RetEventoCTe.InfEvento.detEvento.infCorrecao[i].nroItemAlterado;
        end;

        for i := 0 to RetEventoCTe.InfEvento.detEvento.infGTV.Count -1 do
        begin
          infEvento.detEvento.infGTV.Add;
          infEvento.detEvento.infGTV[i].nDoc     := RetEventoCTe.InfEvento.detEvento.infGTV[i].nDoc;
          infEvento.detEvento.infGTV[i].id       := RetEventoCTe.InfEvento.detEvento.infGTV[i].id;
          infEvento.detEvento.infGTV[i].serie    := RetEventoCTe.InfEvento.detEvento.infGTV[i].serie;
          infEvento.detEvento.infGTV[i].subserie := RetEventoCTe.InfEvento.detEvento.infGTV[i].subserie;
          infEvento.detEvento.infGTV[i].dEmi     := RetEventoCTe.InfEvento.detEvento.infGTV[i].dEmi;
          infEvento.detEvento.infGTV[i].nDV      := RetEventoCTe.InfEvento.detEvento.infGTV[i].nDV;
          infEvento.detEvento.infGTV[i].qCarga   := RetEventoCTe.InfEvento.detEvento.infGTV[i].qCarga;

          for j := 0 to RetEventoCTe.InfEvento.detEvento.infGTV[i].infEspecie.Count -1 do
          begin
            infEvento.detEvento.infGTV[i].infEspecie.Add;
            infEvento.detEvento.infGTV[i].infEspecie[j].tpEspecie := RetEventoCTe.InfEvento.detEvento.infGTV[i].infEspecie[j].tpEspecie;
            infEvento.detEvento.infGTV[i].infEspecie[j].vEspecie  := RetEventoCTe.InfEvento.detEvento.infGTV[i].infEspecie[j].vEspecie;
          end;

          infEvento.detEvento.infGTV[i].rem.CNPJCPF := RetEventoCTe.InfEvento.detEvento.infGTV[i].rem.CNPJCPF;
          infEvento.detEvento.infGTV[i].rem.IE      := RetEventoCTe.InfEvento.detEvento.infGTV[i].rem.IE;
          infEvento.detEvento.infGTV[i].rem.UF      := RetEventoCTe.InfEvento.detEvento.infGTV[i].rem.UF;
          infEvento.detEvento.infGTV[i].rem.xNome   := RetEventoCTe.InfEvento.detEvento.infGTV[i].rem.xNome;

          infEvento.detEvento.infGTV[i].dest.CNPJCPF := RetEventoCTe.InfEvento.detEvento.infGTV[i].dest.CNPJCPF;
          infEvento.detEvento.infGTV[i].dest.IE      := RetEventoCTe.InfEvento.detEvento.infGTV[i].dest.IE;
          infEvento.detEvento.infGTV[i].dest.UF      := RetEventoCTe.InfEvento.detEvento.infGTV[i].dest.UF;
          infEvento.detEvento.infGTV[i].dest.xNome   := RetEventoCTe.InfEvento.detEvento.infGTV[i].dest.xNome;

          infEvento.detEvento.infGTV[i].placa    := RetEventoCTe.InfEvento.detEvento.infGTV[i].placa;
          infEvento.detEvento.infGTV[i].UF       := RetEventoCTe.InfEvento.detEvento.infGTV[i].UF;
          infEvento.detEvento.infGTV[i].RNTRC    := RetEventoCTe.InfEvento.detEvento.infGTV[i].RNTRC;
        end;

        if RetEventoCTe.retEvento.Count > 0 then
         begin
           FRetInfEvento.Id          := RetEventoCTe.retEvento.Items[0].RetInfEvento.Id;
           FRetInfEvento.tpAmb       := RetEventoCTe.retEvento.Items[0].RetInfEvento.tpAmb;
           FRetInfEvento.verAplic    := RetEventoCTe.retEvento.Items[0].RetInfEvento.verAplic;
           FRetInfEvento.cOrgao      := RetEventoCTe.retEvento.Items[0].RetInfEvento.cOrgao;
           FRetInfEvento.cStat       := RetEventoCTe.retEvento.Items[0].RetInfEvento.cStat;
           FRetInfEvento.xMotivo     := RetEventoCTe.retEvento.Items[0].RetInfEvento.xMotivo;
           FRetInfEvento.chCTe       := RetEventoCTe.retEvento.Items[0].RetInfEvento.chCTe;
           FRetInfEvento.tpEvento    := RetEventoCTe.retEvento.Items[0].RetInfEvento.tpEvento;
           FRetInfEvento.xEvento     := RetEventoCTe.retEvento.Items[0].RetInfEvento.xEvento;
           FRetInfEvento.nSeqEvento  := RetEventoCTe.retEvento.Items[0].RetInfEvento.nSeqEvento;
           FRetInfEvento.CNPJDest    := RetEventoCTe.retEvento.Items[0].RetInfEvento.CNPJDest;
           FRetInfEvento.emailDest   := RetEventoCTe.retEvento.Items[0].RetInfEvento.emailDest;
           FRetInfEvento.dhRegEvento := RetEventoCTe.retEvento.Items[0].RetInfEvento.dhRegEvento;
           FRetInfEvento.nProt       := RetEventoCTe.retEvento.Items[0].RetInfEvento.nProt;
           FRetInfEvento.XML         := RetEventoCTe.retEvento.Items[0].RetInfEvento.XML;
         end;
      end;
  finally
     RetEventoCTe.Free;
  end;
end;

function TEventoCTe.ObterNomeArquivo(tpEvento: TpcnTpEvento): string;
begin
 case tpEvento of
    teCCe         : Result := IntToStr(Self.idLote) + '-cce.xml';
    teCancelamento: Result := Evento.Items[0].InfEvento.chCTe + '-can-eve.xml';
    teEPEC        : Result := Evento.Items[0].InfEvento.chCTe + '-ped-epec.xml';
  else
    raise EventoCTeException.Create('Obter nome do arquivo de Evento n�o Implementado!');
 end;
end;

function TEventoCTe.LerFromIni(const AIniString: String;
  CCe: Boolean): Boolean;
var
  I, J, K: Integer;
  sSecao, sFim: String;
  INIRec: TMemIniFile;
  ok: Boolean;
begin
  Result := False;
  Self.Evento.Clear;

  INIRec := TMemIniFile.Create('');
  try
    LerIniArquivoOuString(AIniString, INIRec);

    idLote := INIRec.ReadInteger('EVENTO', 'idLote', 0);

    I := 1;
    while true do
    begin
      sSecao := 'EVENTO'+IntToStrZero(I,3);
      sFim   := INIRec.ReadString(sSecao, 'chCTe', 'FIM');
      if (sFim = 'FIM') or (Length(sFim) <= 0) then
        break;

      with Self.Evento.Add do
      begin
        infEvento.chCTe              := INIRec.ReadString(sSecao, 'chCTe', '');
        infEvento.cOrgao             := INIRec.ReadInteger(sSecao, 'cOrgao', 0);
        infEvento.CNPJ               := INIRec.ReadString(sSecao, 'CNPJ', '');
        infEvento.dhEvento           := StringToDateTime(INIRec.ReadString(sSecao, 'dhEvento', ''));
        infEvento.tpEvento           := StrToTpEvento(ok, INIRec.ReadString(sSecao, 'tpEvento', ''));
        infEvento.nSeqEvento         := INIRec.ReadInteger(sSecao, 'nSeqEvento', 1);
        infEvento.detEvento.xCondUso := '';
        infEvento.detEvento.xJust    := INIRec.ReadString(sSecao, 'xJust', '');
        infEvento.detEvento.nProt    := INIRec.ReadString(sSecao, 'nProt', '');

        case InfEvento.tpEvento of
          teEPEC:
            begin
              infEvento.detEvento.vICMS   := StringToFloatDef(INIRec.ReadString(sSecao, 'vICMS', ''), 0);
              infEvento.detEvento.vTPrest := StringToFloatDef(INIRec.ReadString(sSecao, 'vTPrest', ''), 0);
              infEvento.detEvento.vCarga  := StringToFloatDef(INIRec.ReadString(sSecao, 'vCarga', ''), 0);
              InfEvento.detEvento.modal   := StrToTpModal(ok, INIRec.ReadString(sSecao, 'modal', '01'));
              infEvento.detEvento.UFIni   := INIRec.ReadString(sSecao, 'UFIni', '');
              infEvento.detEvento.UFFim   := INIRec.ReadString(sSecao, 'UFFim', '');
              infEvento.detEvento.dhEmi   := StringToDateTime(INIRec.ReadString(sSecao, 'dhEmi', ''));

              infEvento.detEvento.toma    := StrToTpTomador(ok, INIRec.ReadString('TOMADOR', 'toma', '1'));
              infEvento.detEvento.UF      := INIRec.ReadString('TOMADOR', 'UF', '');
              infEvento.detEvento.CNPJCPF := INIRec.ReadString('TOMADOR', 'CNPJCPF', '');
              infEvento.detEvento.IE      := INIRec.ReadString('TOMDOR', 'IE', '');
            end;

          teCCe:
            begin
              Self.Evento.Items[I-1].InfEvento.detEvento.infCorrecao.Clear;

              J := 1;
              while true do
              begin
                sSecao := 'DETEVENTO' + IntToStrZero(J, 3);
                sFim   := INIRec.ReadString(sSecao, 'grupoAlterado', 'FIM');
                if (sFim = 'FIM') or (Length(sFim) <= 0) then
                  break;

                with Self.Evento.Items[I-1].InfEvento.detEvento.infCorrecao.Add do
                begin
                  grupoAlterado   := INIRec.ReadString(sSecao, 'grupoAlterado', '');
                  campoAlterado   := INIRec.ReadString(sSecao, 'campoAlterado', '');
                  valorAlterado   := INIRec.ReadString(sSecao, 'valorAlterado', '');
                  nroItemAlterado := INIRec.ReadInteger(sSecao, 'nroItemAlterado', 0);
                end;
                Inc(J);
              end;
            end;

          teMultiModal:
            begin
              infEvento.detEvento.xRegistro := INIRec.ReadString(sSecao, 'xRegistro', '');
              infEvento.detEvento.nDoc      := INIRec.ReadString(sSecao, 'nDoc', '');
            end;

          tePrestDesacordo:
            begin
              infEvento.detEvento.xOBS := INIRec.ReadString(sSecao, 'nObs', '');
            end;

          teGTV:
            begin
              Self.Evento.Items[I-1].InfEvento.detEvento.infGTV.Clear;

              J := 1;
              while true do
              begin
                sSecao := 'infGTV' + IntToStrZero(J, 3);
                sFim   := INIRec.ReadString(sSecao, 'nDoc', 'FIM');
                if (sFim = 'FIM') or (Length(sFim) <= 0) then
                  break;

                with Self.Evento.Items[I-1].InfEvento.detEvento.infGTV.Add do
                begin
                  nDoc     := sFim;
                  id       := INIRec.ReadString(sSecao, 'id', '');
                  serie    := INIRec.ReadString(sSecao, 'serie', '');
                  subserie := INIRec.ReadString(sSecao, 'subserie', '');
                  dEmi     := StringToDateTime(INIRec.ReadString(sSecao, 'dEmi', ''));
                  nDV      := INIRec.ReadInteger(sSecao, 'nDV', 0);
                  qCarga   := StringToFloatDef(INIRec.ReadString(sSecao, 'qCarga', ''), 0);
                  placa    := INIRec.ReadString(sSecao, 'placa', '');
                  UF       := INIRec.ReadString(sSecao, 'UF', '');
                  RNTRC    := INIRec.ReadString(sSecao, 'RNTRC', '');
                end;

                Self.Evento.Items[I-1].InfEvento.detEvento.infGTV.Items[J].infEspecie.Clear;

                K := 1;
                while true do
                begin
                  sSecao := 'infEspecie' + IntToStrZero(J, 3) + IntToStrZero(K, 3);
                  sFim   := INIRec.ReadString(sSecao, 'tpEspecie', 'FIM');
                  if (sFim = 'FIM') or (Length(sFim) <= 0) then
                    break;

                  with Self.Evento.Items[I-1].InfEvento.detEvento.infGTV.Items[J].infEspecie.Add do
                  begin
                    tpEspecie := StrToTEspecie(Ok, sFim);
                    vEspecie  := StringToFloatDef(INIRec.ReadString(sSecao, 'vEspecie', ''), 0);
                  end;
                  Inc(K);
                end;

                sSecao := 'rem' + IntToStrZero(J, 3);
                sFim   := INIRec.ReadString(sSecao, 'CNPJCPF', 'FIM');
                if (sFim = 'FIM') or (Length(sFim) <= 0) then
                  break;

                with Self.Evento.Items[I-1].InfEvento.detEvento.infGTV.Items[J].rem do
                begin
                  CNPJCPF := sFim;
                  IE      := INIRec.ReadString(sSecao, 'IE', '');
                  UF      := INIRec.ReadString(sSecao, 'UF', '');
                  xNome   := INIRec.ReadString(sSecao, 'xNome', '');
                end;

                sSecao := 'dest' + IntToStrZero(J, 3);
                sFim   := INIRec.ReadString(sSecao, 'CNPJCPF', 'FIM');
                if (sFim = 'FIM') or (Length(sFim) <= 0) then
                  break;

                with Self.Evento.Items[I-1].InfEvento.detEvento.infGTV.Items[J].dest do
                begin
                  CNPJCPF := sFim;
                  IE      := INIRec.ReadString(sSecao, 'IE', '');
                  UF      := INIRec.ReadString(sSecao, 'UF', '');
                  xNome   := INIRec.ReadString(sSecao, 'xNome', '');
                end;

                Inc(J);
              end;
            end;
        end;
      end;
      Inc(I);
    end;

    Result := True;
  finally
     INIRec.Free;
  end;
end;

{ TInfEventoCollection }

function TInfEventoCollection.Add: TInfEventoCollectionItem;
begin
  Result := TInfEventoCollectionItem(inherited Add);
  Result.create;
end;

constructor TInfEventoCollection.Create(AOwner: TPersistent);
begin
  inherited Create(TInfEventoCollectionItem);
end;

function TInfEventoCollection.GetItem(
  Index: Integer): TInfEventoCollectionItem;
begin
  Result := TInfEventoCollectionItem(inherited GetItem(Index));
end;

procedure TInfEventoCollection.SetItem(Index: Integer;
  Value: TInfEventoCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TInfEventoCollectionItem }

constructor TInfEventoCollectionItem.Create;
begin
  FInfEvento := TInfEvento.Create;
  Fsignature := Tsignature.Create;
  FRetInfEvento := TRetInfEvento.Create;
end;

destructor TInfEventoCollectionItem.Destroy;
begin
  FInfEvento.Free;
  Fsignature.Free;
  FRetInfEvento.Free;
  inherited;
end;

end.
