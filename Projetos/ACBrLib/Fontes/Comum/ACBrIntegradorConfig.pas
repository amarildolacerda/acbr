{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
{ mentos de Automação Comercial utilizados no Brasil                           }

{ Direitos Autorais Reservados (c) 2018 Daniel Simoes de Almeida               }

{ Colaboradores nesse arquivo: Rafael Teno Dias                                }

{  Você pode obter a última versão desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }

{  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
{ sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
{ qualquer versão posterior.                                                   }

{  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU      }
{ ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)              }

{  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto}
{ com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,  }
{ no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Você também pode obter uma copia da licença em:                              }
{ http://www.opensource.org/licenses/gpl-license.php                           }

{ Daniel Simões de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{        Rua Cel.Aureliano de Camargo, 973 - Tatuí - SP - 18270-170            }

{******************************************************************************}

{$I ACBr.inc}

unit ACBrIntegradorConfig;

interface

uses
  Classes, SysUtils, IniFiles,
  synachar;

type

  { TIntegradorConfig }

  TIntegradorConfig = class
  private
    FArqLOG: String;
    FPastaInput: String;
    FPastaOutput: String;
    FTimeout: Integer;

  public
    constructor Create;

    procedure DefinirValoresPadroes;
    procedure LerIni(const AIni: TCustomIniFile);
    procedure GravarIni(const AIni: TCustomIniFile);

    property ArqLOG: String read FArqLOG write FArqLOG ;
    property PastaInput: String read FPastaInput write FPastaInput;
    property PastaOutput: String  read FPastaOutput write FPastaOutput;
    property Timeout: Integer read FTimeout write FTimeout;

  end;
  

implementation

uses
  ACBrLibConsts, ACBrLibComum,
  ACBrUtil;

{ TIntegradorConfig }

constructor TIntegradorConfig.Create;
begin
  inherited Create;

  DefinirValoresPadroes;
end;

procedure TIntegradorConfig.DefinirValoresPadroes;
begin
  FArqLOG := '';
  FPastaInput := 'C:\Integrador\Input\';
  FPastaOutput := 'C:\Integrador\Output\';
  FTimeout := 30;
end;

procedure TIntegradorConfig.LerIni(const AIni: TCustomIniFile);
begin
  FArqLOG := AIni.ReadString(CChaveIntegrador, CChaveArqLog, FArqLOG);
  FPastaInput := AIni.ReadString(CChaveIntegrador, CChavePastaInput, FPastaInput);
  FPastaOutput := AIni.ReadString(CChaveIntegrador, CChavePastaOutput, FPastaOutput);
  FTimeout := AIni.ReadInteger(CChaveIntegrador, CChaveTimeout, FTimeout);
end;

procedure TIntegradorConfig.GravarIni(const AIni: TCustomIniFile);
begin
  AIni.WriteString(CChaveIntegrador, CChaveArqLog, FArqLOG);
  AIni.WriteString(CChaveIntegrador, CChavePastaInput, FPastaInput);
  AIni.WriteString(CChaveIntegrador, CChavePastaOutput, FPastaOutput);
  AIni.WriteInteger(CChaveIntegrador, CChaveTimeout, FTimeout);
end;

end.
