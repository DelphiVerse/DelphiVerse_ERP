CREATE TABLE intellisoft_gil.clientes (
	id INTEGER auto_increment NOT NULL,
	razao_social varchar(100) NOT NULL,
	nome_fantasia varchar(100) NULL,
	cpf_cnpj varchar(15) NOT NULL,
	status varchar(1) DEFAULT 'A' NOT NULL,
	CONSTRAINT clientes_pk PRIMARY KEY (id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8
COLLATE=utf8_general_ci;

ALTER TABLE intellisoft_gil.clientes ADD telefone varchar(11) NULL;
ALTER TABLE intellisoft_gil.clientes ADD email varchar(100) NULL;

ALTER TABLE `clientes` 
  -- Informações de Localização (Essenciais para qualquer cadastro)
  ADD COLUMN `cep` VARCHAR(8) DEFAULT NULL AFTER `email`,
  ADD COLUMN `endereco` VARCHAR(100) DEFAULT NULL AFTER `cep`,
  ADD COLUMN `numero` VARCHAR(10) DEFAULT NULL AFTER `endereco`,
  ADD COLUMN `complemento` VARCHAR(50) DEFAULT NULL AFTER `numero`,
  ADD COLUMN `bairro` VARCHAR(50) DEFAULT NULL AFTER `complemento`,
  ADD COLUMN `cidade` VARCHAR(50) DEFAULT NULL AFTER `bairro`,
  ADD COLUMN `uf` VARCHAR(2) DEFAULT NULL AFTER `cidade`,

  -- Informações de Pessoa Física/Jurídica adicionais
  ADD COLUMN `rg_ie` VARCHAR(20) DEFAULT NULL COMMENT 'RG ou Inscrição Estadual' AFTER `cpf_cnpj`,

  -- Controle Interno e Auditoria (Fundamentais para gestão)
  ADD COLUMN `data_cadastro` DATETIME DEFAULT CURRENT_TIMESTAMP AFTER `status`,
  ADD COLUMN `observacoes` TEXT DEFAULT NULL AFTER `data_cadastro`;
  
CREATE TABLE intellisoft_gil.planos (
	ID INTEGER auto_increment NOT NULL,
	NOME varchar(100) NOT NULL,
	VALOR DECIMAL(6,2) NULL,
	CONSTRAINT planos_pk PRIMARY KEY (ID)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8
COLLATE=utf8_general_ci;

ALTER TABLE intellisoft_gil.clientes ADD tipo_pessoa INTEGER NOT NULL;

CREATE TABLE tenants (
    id VARCHAR(36) NOT NULL,
    nome_fantasia VARCHAR(150) NOT NULL,
    razao_social VARCHAR(150) NOT NULL,
    cnpj VARCHAR(14) NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	status varchar(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT pk_tenants PRIMARY KEY (id),
    CONSTRAINT uk_tenants_cnpj UNIQUE (cnpj)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Tabela: planos
-- Representa o "porte" ou "infraestrutura" da licença (Ex: Bronze, Prata, Ouro)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `planos` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `descricao` TEXT NULL,
  `valor_base` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Valor fixo do porte do plano',
  `limite_usuarios` INT UNSIGNED NOT NULL DEFAULT 1,
  `status` VARCHAR(1) NOT NULL DEFAULT 'A',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_planos_nome_unico` (`nome` ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Tabela: modulos
-- Representa o nicho de mercado ou vertical do ERP (Ex: Petshop, Oficina, Supermercado)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `modulos` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL COMMENT 'Nome do nicho/vertical',
  `chave_identificadora` VARCHAR(50) NOT NULL COMMENT 'Ex: NICHO_PET, NICHO_AUTO. Usado para travar/liberar o FMX.',
  `descricao` TEXT NULL,
  `valor_adicional` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Valor cobrado por este nicho específico',
  `status` ENUM('ATIVO', 'INATIVO') NOT NULL DEFAULT 'ATIVO',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_modulos_chave_unica` (`chave_identificadora` ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exemplo conceitual da tabela de licenças
CREATE TABLE IF NOT EXISTS `licencas` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cliente_id` INT UNSIGNED NOT NULL,
  `modulo_id` INT UNSIGNED NOT NULL, -- O Nicho escolhido
  `plano_id` INT UNSIGNED NOT NULL,  -- O Porte escolhido
  `valor_total` DECIMAL(10,2) NOT NULL COMMENT 'Calculado via backend: planos.valor_base + modulos.valor_adicional',
  `data_vencimento` DATE NOT NULL,
  `status` ENUM('ATIVA', 'SUSPENSA', 'CANCELADA') NOT NULL DEFAULT 'ATIVA',
  PRIMARY KEY (`id`)
);

ALTER TABLE `faturas` 
ADD COLUMN `pix_copia_cola` TEXT NULL COMMENT 'Linha digitável do PIX gerada pela K8' AFTER `id_integracao`,
ADD COLUMN `pix_qrcode_base64` TEXT NULL COMMENT 'Imagem em Base64 do QRCode para o FMX desenhar' AFTER `pix_copia_cola`;

-- -----------------------------------------------------
-- Tabela: faturas (Versão Corrigida)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `faturas` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cliente_id` INT(11) NOT NULL,
  `licenca_id` INT(10) UNSIGNED NOT NULL,
  `valor` DECIMAL(10,2) NOT NULL,
  `data_emissao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_vencimento` DATE NOT NULL,
  `data_pagamento` DATETIME NULL,
  `forma_pagamento` ENUM('BOLETO', 'PIX', 'CARTAO', 'TRANSFERENCIA') NULL,
  `status` ENUM('PENDENTE', 'PAGO', 'VENCIDO', 'CANCELADO') NOT NULL DEFAULT 'PENDENTE',
  `link_checkout` VARCHAR(255) NULL,
  `id_integracao` VARCHAR(100) NULL,
  `pix_copia_cola` TEXT NULL,
  `pix_qrcode_base64` TEXT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_faturas_status` (`status` ASC),
  CONSTRAINT `fk_faturas_clientes`
    FOREIGN KEY (`cliente_id`)
    REFERENCES `clientes` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_faturas_licencas`
    FOREIGN KEY (`licenca_id`)
    REFERENCES `licencas` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE intellisoft_gil.modulos MODIFY COLUMN status VARCHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'A' NOT NULL;

ALTER TABLE intellisoft_gil.licencas MODIFY COLUMN status VARCHAR(1) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT 'A' NOT NULL;

-- -----------------------------------------------------
-- Tabela: centro_custos
-- Representa os setores, departamentos ou projetos (Ex: Diretoria, Vendas, TI, Projeto Alfa)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `centro_custos` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `status` VARCHAR(1) NOT NULL DEFAULT 'A',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Tabela: plano_contas
-- Categorias de classificação financeira (Ex: Venda de Produtos, Conta de Luz, Salários)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `plano_contas` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo_contabil` VARCHAR(20) NULL COMMENT 'Ex: 1.01.01 (Estrutura de árvore)',
  `nome` VARCHAR(100) NOT NULL,
  `tipo` ENUM('RECEITA', 'DESPESA') NOT NULL COMMENT 'Define se a categoria é de entrada ou saída',
  `status` VARCHAR(1) NOT NULL DEFAULT 'A',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Tabela: lancamentos_financeiros (Dados Financeiros)
-- Armazena o Contas a Pagar e Contas a Receber unificados
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `lancamentos_financeiros` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tipo_lancamento` ENUM('PAGAR', 'RECEBER') NOT NULL,
  `pessoa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Pode ser ID do Cliente, Fornecedor ou Funcionário',
  `plano_conta_id` BIGINT UNSIGNED NOT NULL,
  `centro_custo_id` BIGINT UNSIGNED NULL COMMENT 'Permite NULL, pois nem todo lançamento exige centro de custo',
  `descricao` VARCHAR(255) NOT NULL COMMENT 'Histórico ou detalhe do lançamento',
  `numero_documento` VARCHAR(50) NULL COMMENT 'Número da Nota Fiscal, Recibo ou Boleto',
  `data_emissao` DATE NOT NULL,
  `data_vencimento` DATE NOT NULL,
  `data_pagamento` DATETIME NULL,
  `valor_original` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `valor_juros_multa` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `valor_desconto` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `valor_pago` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `status` VARCHAR(1) NOT NULL DEFAULT 'A' COMMENT 'A=ABERTO, B=BAIXADO, P=PARCIAL, C=CANCELADO',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_alteracao` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_lancamentos_vencimento` (`data_vencimento` ASC),
  INDEX `idx_lancamentos_status` (`status` ASC),
  CONSTRAINT `fk_lancamentos_planoconta`
    FOREIGN KEY (`plano_conta_id`)
    REFERENCES `plano_contas` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_lancamentos_centrocusto`
    FOREIGN KEY (`centro_custo_id`)
    REFERENCES `centro_custos` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE intellisoft_gil.lancamentos_financeiros MODIFY COLUMN tipo_lancamento enum('DÉBITO','CRÉDITO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- -----------------------------------------------------
-- Tabela: baixas_financeiras (Histórico de Pagamentos/Recebimentos)
-- Permite múltiplas baixas (parciais) para um único lançamento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `baixas_financeiras` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `lancamento_id` BIGINT UNSIGNED NOT NULL COMMENT 'Obrigatório: a que conta este pagamento pertence',
  `conta_bancaria_id` BIGINT UNSIGNED NULL COMMENT 'Para conciliação bancária',
  -- Informações da Transação
  `data_baixa` DATE NOT NULL COMMENT 'Data em que o dinheiro efetivamente entrou/saiu',
  `valor_pago` DECIMAL(15,2) NOT NULL COMMENT 'Valor base pago nesta operação',
  `valor_juros` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `valor_multa` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `valor_desconto` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  -- Métodos e Rastreio
  `forma_pagamento` ENUM('DINHEIRO', 'PIX', 'TRANSFERENCIA', 'BOLETO', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'CHEQUE', 'OUTROS') NOT NULL,
  `codigo_transacao` VARCHAR(100) NULL COMMENT 'Ex: ID da transação do PIX da K8 Fintech',
  `observacao` VARCHAR(255) NULL,
  -- Auditoria
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` BIGINT UNSIGNED NULL COMMENT 'Saber quem fez a baixa no sistema',
  PRIMARY KEY (`id`),
  INDEX `idx_baixas_lancamento` (`lancamento_id` ASC),
  INDEX `idx_baixas_data` (`data_baixa` ASC),
  CONSTRAINT `fk_baixas_lancamento`
    FOREIGN KEY (`lancamento_id`)
    REFERENCES `lancamentos_financeiros` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

