unit untConstantes;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Rtti,
  System.Bindings.Outputs;

const
  //--------------CONFIGURAÇÕES------------------
  _BASE_URL = 'http://';
  _USER_API = 'intellisoftGIL';
  _PASSWORD_API = 'G1l2026';

  //-------------TECLAS DE ATALHO----------------
  _TECLA_ATALHO = vkF8;

  //-------------MENSAGENS-----------------------
  _MENSAGEM_BOTAO_EDICAO        = 'Para editar esse registro, primeiro clique no botão EDITAR!';
  _MENSAGEM_GRAVACAO            = 'Deseja gravar?';
  _MENSAGEM_EXCLUSAO            = 'Confirma a EXCLUSÃO desse registro?';
  _MENSAGEM_SUCESSO_GRAVACAO    = 'Registro gravado com sucesso!';
  _MENSAGEM_FALHA_GRAVACAO      = 'Falha %s ao gravar o registro.';
  _MENSAGEM_FALHA_EXCLUSAO      = 'Falha ao excluir o registro.';
  _MENSAGEM_SUCESSO_EXCLUSAO    = 'Registro excluído com sucesso.';
  _MENSAGEM_NAO_ENCONTRADA      = 'Não encontrei a %s, tente pelo botão de pesquisa!';
  _MENSAGEM_NAO_ENCONTRADO      = 'Não encontrei o %s, tente pelo botão de pesquisa!';
  _MENSAGEM_CAMPO_VAZIO         = 'O campo %S deve ser preenchido!';
  _MENSAGEM_SEM_DADOS_GRAVACAO  = 'Não há dados a serem gravados!';

  //-------------OPERAÇÕES-----------------------
  _INSERCAO  = 1;
  _EDICAO    = 2;
  _EXCLUSAO  = 3;

  //---------NOMES DE RELATÓRIO------------------
  RELATORIO_GERAL         = 1;
  RELATORIO_IMPOSTO_RENDA = 2;

  //---------MODOS DE OPEÇÃO---------------------
  MODO_INSERCAO = 1;
  MODO_EDICAO   = 2;
  MODO_EXCLUSAO = 3;

  //---------TIPOS DE TITULOS--------------------
  TP_TITULO_PAGAR   = 1;
  TP_TITULO_RECEBER = 2;

  //---------TABELAS DE PEQUISA------------------
  TB_PESQUISA_GRUPO_RECEITAS = 0;
  TB_PESQUISA_GRUPO_DESPESAS = 1;
  TB_PESQUISA_CENTROS_CUSTO  = 2;
  TB_PESQUISA_RECEITAS       = 3;
  TB_PESQUISA_DESPESAS       = 4;
  TB_PESQUISA_PESSOA         = 5;
  TB_PESQUISA_FORNECEDORES   = 6;
  TB_PESQUISA_FUNCIONARIOS   = 7;
  TB_PESQUISA_CIDADES        = 8;
  TB_PESQUISA_ESPECIE        = 9;
  TB_PESQUISA_RACA           = 10;
  TB_PESQUISA_PETS           = 11;
  TB_PESQUISA_PRODUTOS       = 12;

implementation

end.
