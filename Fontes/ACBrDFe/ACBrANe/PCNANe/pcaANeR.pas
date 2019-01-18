{******************************************************************************}
{ Projeto: Componente ACBrANe                                                  }
{  Biblioteca multiplataforma de componentes Delphi                            }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }
{                                                                              }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{*******************************************************************************
|* Historico
|*
|* 24/02/2016: Italo Jurisato Junior
|*  - Doa��o do componente para o Projeto ACBr
*******************************************************************************}

{$I ACBr.inc}

unit pcaANeR;

interface

uses
  SysUtils, Classes,
{$IFNDEF VER130}
  Variants,
{$ENDIF}
  ACBrUtil, pcnAuxiliar, pcnConversao, pcnLeitor, pcaConversao, pcaANe;

type

  TANeR = class(TPersistent)
  private
    FLeitor: TLeitor;
    FANe: TANe;
  public
    constructor Create(AOwner: TANe);
    destructor Destroy; override;
    function LerXml: Boolean;
  published
    property Leitor: TLeitor read FLeitor write FLeitor;
    property ANe: TANe       read FANe    write FANe;
  end;

implementation

{ TANeR }

constructor TANeR.Create(AOwner: TANe);
begin
  inherited Create;
  FLeitor := TLeitor.Create;
  FANe := AOwner;
end;

destructor TANeR.Destroy;
begin
  FLeitor.Free;
  
  inherited Destroy;
end;

function TANeR.LerXml: Boolean;
begin
  Leitor.Grupo := Leitor.Arquivo;

  ANe.usuario := Leitor.rCampo(tcStr, 'usuario');
  ANe.senha   := Leitor.rCampo(tcStr, 'senha');
  ANe.codatm  := Leitor.rCampo(tcStr, 'codatm');

  ANe.xmlDFe := Leitor.rCampo(tcStr, 'xmlCTe');

  if ANe.xmlDFe = '' then
    ANe.xmlDFe := Leitor.rCampo(tcStr, 'xmlNFe');

  if ANe.xmlDFe = '' then
    ANe.xmlDFe := Leitor.rCampo(tcStr, 'xmlMDFe');

  ANe.xmlDFe := StringReplace(ANe.xmlDFe, '<![CDATA[', '', [rfReplaceAll]);
  ANe.xmlDFe := StringReplace(ANe.xmlDFe, ']]>', '', [rfReplaceAll]);

  ANe.aplicacao     := Leitor.rCampo(tcStr, 'aplicacao');
  ANe.assunto       := Leitor.rCampo(tcStr, 'assunto');
  ANe.remetentes    := Leitor.rCampo(tcStr, 'remetentes');
  ANe.destinatarios := Leitor.rCampo(tcStr, 'destinatarios');
  ANe.corpo         := Leitor.rCampo(tcStr, 'corpo');
  ANe.chave         := Leitor.rCampo(tcStr, 'chave');
  ANe.chaveresp     := Leitor.rCampo(tcStr, 'chaveresp');

  Result := True;
end;

end.

