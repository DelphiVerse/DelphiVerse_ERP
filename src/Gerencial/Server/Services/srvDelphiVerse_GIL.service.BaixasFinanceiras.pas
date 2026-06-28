unit srvDelphiVerse_GIL.service.BaixasFinanceiras;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

  ServerGIL.providers.ProviderConnection,
  DataSet.Serialize,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TdmGILConnectBaixasFinanceiras = class(TdmGILConnect)
  private
    { Private declarations }
  public
    { Public declarations }
    function ListarPorLancamento(const ALancamentoId: Int64): TFDQuery;
    function Inserir(const AJson: TJSONObject): Boolean;
    function Deletar(const AId: Int64): Boolean;
    function ListarPorId(const AId: Int64): TFDQuery;
    function Atualizar(const AId: Int64; const AJson: TJSONObject): Boolean;
  end;

var
  dmGILConnectBaixasFinanceiras: TdmGILConnectBaixasFinanceiras;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnectBaixasFinanceiras }

function TdmGILConnectBaixasFinanceiras.Deletar(const AId: Int64): Boolean;
var
  vLancamentoId: Int64;
  vValorBaixaExcluida, vValorPagoAtual, vValorOriginal: Currency;
  vNovoStatus: string;
  qryLancamento: TFDQuery;
begin
  Result := False;

  // Busca os dados da baixa antes de excluí-la para sabermos quanto estornar
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT lancamento_id, valor_pago FROM baixas_financeiras WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.CachedUpdates:= True;
  qryAux.Open;

  if qryAux.IsEmpty then
    raise Exception.Create('Baixa financeira não encontrada.');

  vLancamentoId       := qryAux.FieldByName('lancamento_id').AsLargeInt;
  vValorBaixaExcluida := qryAux.FieldByName('valor_pago').AsCurrency;

  conConnectGIL.StartTransaction;
  try
    // PASSO 1: EXCLUIR A BAIXA
    qryAux.Delete;
    if qryAux.ApplyUpdates(0) > 0 then
      raise Exception.Create('Falha ao excluir o registro de baixa financeira.');

    // PASSO 2: ESTORNAR O VALOR NO LANÇAMENTO PRINCIPAL
    qryLancamento := TFDQuery.Create(nil);
    try
      qryLancamento.Connection := conConnectGIL;
      // FOR UPDATE para evitar concorrência durante o estorno
      qryLancamento.CachedUpdates:= True;
      qryLancamento.SQL.Text := 'SELECT id, valor_original, valor_pago, data_pagamento, status FROM lancamentos_financeiros WHERE id = :id FOR UPDATE';
      qryLancamento.ParamByName('id').AsLargeInt := vLancamentoId;
      qryLancamento.Open;

      if not qryLancamento.IsEmpty then
      begin
        vValorOriginal  := qryLancamento.FieldByName('valor_original').AsCurrency;
        vValorPagoAtual := qryLancamento.FieldByName('valor_pago').AsCurrency;

        // Subtrai o valor que foi pago equivocadamente
        vValorPagoAtual := vValorPagoAtual - vValorBaixaExcluida;

        // Proteção contra valores negativos (caso extremo)
        if vValorPagoAtual <= 0 then
        begin
          vValorPagoAtual := 0;
          vNovoStatus := 'ABERTO';
        end
        else if vValorPagoAtual < vValorOriginal then
          vNovoStatus := 'PARCIAL'
        else
          vNovoStatus := 'BAIXADO'; // Mantém pago se por algum motivo ainda sobrar valor igual ou maior

        // Atualiza a tabela principal
        qryLancamento.Edit;
        qryLancamento.FieldByName('valor_pago').AsCurrency := vValorPagoAtual;
        qryLancamento.FieldByName('status').AsString := vNovoStatus;

        // Se zerou tudo, limpa a data de pagamento
        if vValorPagoAtual = 0 then
          qryLancamento.FieldByName('data_pagamento').Clear;

        qryLancamento.Post;

        if qryLancamento.ApplyUpdates(0) > 0 then
          raise Exception.Create('Falha ao estornar o valor do lançamento financeiro principal.');
      end;
    finally
      qryLancamento.Free;
    end;

    conConnectGIL.Commit;
    Result := True;
  except
    conConnectGIL.Rollback;
    raise;
  end;
end;

function TdmGILConnectBaixasFinanceiras.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM baixas_financeiras WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectBaixasFinanceiras.Atualizar(const AId: Int64; const AJson: TJSONObject): Boolean;
var
  vLancamentoId: Int64;
  vValorBaixaAntigo, vValorBaixaNovo, vDiferenca, vValorPagoAtual, vValorOriginal: Currency;
  vNovoStatus: string;
  qryLancamento: TFDQuery;
begin
  Result := False;

  // 1. Busca os valores antigos ANTES da alteração para sabermos a diferença matemática
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT lancamento_id, valor_pago FROM baixas_financeiras WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;

  if qryAux.IsEmpty then
    raise Exception.Create('Baixa financeira não encontrada.');

  vLancamentoId     := qryAux.FieldByName('lancamento_id').AsLargeInt;
  vValorBaixaAntigo := qryAux.FieldByName('valor_pago').AsCurrency;

  conConnectGIL.StartTransaction;
  try
    // 2. Mescla o JSON e atualiza a Baixa
    qryAux.Close;
    qryAux.SQL.Text := 'SELECT * FROM baixas_financeiras WHERE id = :id';
    qryAux.ParamByName('id').AsLargeInt := AId;

    qryAux.UpdateOptions.UpdateTableName := 'baixas_financeiras';
    qryAux.UpdateOptions.KeyFields := 'id';
    qryAux.UpdateOptions.RefreshMode := rmManual;
    qryAux.UpdateOptions.CountUpdatedRecords := False;
    qryAux.CachedUpdates:= True;
    qryAux.Open;
    qryAux.MergeFromJSONObject(AJson, False);

    // Captura o novo valor pago (caso o utilizador tenha alterado no JSON)
    vValorBaixaNovo := qryAux.FieldByName('valor_pago').AsCurrency;

    if qryAux.ApplyUpdates(0) > 0 then
      raise Exception.Create('Falha ao atualizar o registro da baixa financeira.');

    // 3. Calcula a diferença e aplica no Lançamento Principal (se o valor foi alterado)
    vDiferenca := vValorBaixaNovo - vValorBaixaAntigo;

    if vDiferenca <> 0 then
    begin
      qryLancamento := TFDQuery.Create(nil);
      try
        qryLancamento.Connection := conConnectGIL;
        qryLancamento.CachedUpdates:= True;
        qryLancamento.SQL.Text := 'SELECT id, valor_original, valor_pago, data_pagamento, status FROM lancamentos_financeiros WHERE id = :id FOR UPDATE';
        qryLancamento.ParamByName('id').AsLargeInt := vLancamentoId;
        qryLancamento.Open;

        if not qryLancamento.IsEmpty then
        begin
          vValorOriginal  := qryLancamento.FieldByName('valor_original').AsCurrency;
          vValorPagoAtual := qryLancamento.FieldByName('valor_pago').AsCurrency;

          // Aplica a diferença (pode ser positiva se pagou mais, ou negativa se pagou menos)
          vValorPagoAtual := vValorPagoAtual + vDiferenca;

          // Proteção contra saldos e reavaliação de status
          if vValorPagoAtual <= 0 then
          begin
            vValorPagoAtual := 0;
            vNovoStatus := 'ABERTO';
          end
          else if vValorPagoAtual < vValorOriginal then
            vNovoStatus := 'PARCIAL'
          else
            vNovoStatus := 'BAIXADO';

          qryLancamento.Edit;
          qryLancamento.FieldByName('valor_pago').AsCurrency := vValorPagoAtual;
          qryLancamento.FieldByName('status').AsString := vNovoStatus;

          if vValorPagoAtual = 0 then
            qryLancamento.FieldByName('data_pagamento').Clear
          else
            qryLancamento.FieldByName('data_pagamento').AsDateTime := Now;

          qryLancamento.Post;

          if qryLancamento.ApplyUpdates(0) > 0 then
            raise Exception.Create('Falha ao reajustar o valor do lançamento financeiro principal.');
        end;
      finally
        qryLancamento.Free;
      end;
    end;

    conConnectGIL.Commit;
    Result := True;
  except
    conConnectGIL.Rollback;
    raise;
  end;
end;

function TdmGILConnectBaixasFinanceiras.Inserir(
  const AJson: TJSONObject): Boolean;
var
  vLancamentoId: Int64;
  vValorBaixa, vValorPagoAtual, vValorOriginal: Currency;
  vNovoStatus: string;
  qryLancamento: TFDQuery;
begin
  Result := False;

  vLancamentoId := AJson.GetValue<Int64>('lancamentoId', 0);
  vValorBaixa   := AJson.GetValue<Currency>('valorPago', 0);

  if vLancamentoId = 0 then
    raise Exception.Create('ID do Lançamento não informado.');

  conConnectGIL.StartTransaction;
  try
    // PASSO 1: INSERIR O REGISTO DE BAIXA
    qryAux.Close;
    qryAux.SQL.Text := 'SELECT * FROM baixas_financeiras WHERE 1 <> 1';
    qryAux.UpdateOptions.UpdateTableName := 'baixas_financeiras';
    qryAux.UpdateOptions.KeyFields := 'id';
    qryAux.UpdateOptions.RefreshMode := rmManual;
    qryAux.UpdateOptions.CountUpdatedRecords := False;
    qryAux.CachedUpdates:= True;
    qryAux.Open;
    qryAux.LoadFromJSON(AJson, False);

    if qryAux.ApplyUpdates(0) > 0 then
      raise Exception.Create('Falha ao gravar o histórico da baixa financeira.');

    // PASSO 2: ATUALIZAR O LANÇAMENTO PRINCIPAL
    qryLancamento := TFDQuery.Create(nil);
    try
      qryLancamento.Connection := conConnectGIL;
      qryLancamento.SQL.Text := 'SELECT id, valor_original, valor_pago, data_pagamento, status FROM lancamentos_financeiros WHERE id = :id FOR UPDATE';
      qryLancamento.ParamByName('id').AsLargeInt := vLancamentoId;
      qryLancamento.CachedUpdates:= True;
      qryLancamento.Open;

      if not qryLancamento.IsEmpty then
      begin
        vValorOriginal  := qryLancamento.FieldByName('valor_original').AsCurrency;
        vValorPagoAtual := qryLancamento.FieldByName('valor_pago').AsCurrency;

        vValorPagoAtual := vValorPagoAtual + vValorBaixa;

        if vValorPagoAtual >= vValorOriginal then
          vNovoStatus := 'BAIXADO'
        else
          vNovoStatus := 'PARCIAL';

        qryLancamento.Edit;
        qryLancamento.FieldByName('valor_pago').AsCurrency := vValorPagoAtual;
        qryLancamento.FieldByName('status').AsString := vNovoStatus;
        qryLancamento.FieldByName('data_pagamento').AsDateTime := Now;
        qryLancamento.Post;

        if qryLancamento.ApplyUpdates(0) > 0 then
          raise Exception.Create('Falha ao atualizar o status do lançamento financeiro.');
      end
      else
        raise Exception.Create('Lançamento financeiro original não encontrado.');
    finally
      qryLancamento.Free;
    end;

    conConnectGIL.Commit;
    Result := True;
  except
    conConnectGIL.Rollback;
    raise;
  end;
end;

function TdmGILConnectBaixasFinanceiras.ListarPorLancamento(
  const ALancamentoId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM baixas_financeiras WHERE lancamento_id = :id ORDER BY data_baixa DESC, id DESC';
  qryAux.ParamByName('id').AsLargeInt := ALancamentoId;
  qryAux.Open;
  Result := qryAux;
end;

end.
