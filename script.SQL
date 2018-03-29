
CREATE TABLE CLIENTE (
       cpf_cliente          VARCHAR(11) NOT NULL,
       nome_cliente         VARCHAR(100),
       telefone_cliente     VARCHAR(15),
       endereco_cliente     VARCHAR(100)
);

CREATE UNIQUE INDEX XPKCLIENTE ON CLIENTE
(
       cpf_cliente                    ASC
);


ALTER TABLE CLIENTE
       ADD PRIMARY KEY (cpf_cliente);


CREATE TABLE COZINHEIRO (
       especialidade        VARCHAR(50) NOT NULL
);


CREATE TABLE CUPOM (
       desconto             DECIMAL(5, 2),
       descricao_cupom      VARCHAR(50) NOT NULL,
       data_validade_cupo   TIMESTAMP
);

CREATE UNIQUE INDEX XPKCUPOM ON CUPOM
(
       descricao_cupom                ASC
);


ALTER TABLE CUPOM
       ADD PRIMARY KEY (descricao_cupom);


CREATE TABLE DELIVERY (
       qtde_pratos          INTEGER,
       forma_pagamento      VARCHAR(100),
       data_delivery        TIMESTAMP,
       tempo_entrega        TIME,
       placa_veiculo        CHAR(7),
       nome_prato           VARCHAR(50) NOT NULL,
       cpf_cliente          VARCHAR(11) NOT NULL,
       descricao_cupom      VARCHAR(50)
);

CREATE UNIQUE INDEX XPKDELIVERY ON DELIVERY
(
       nome_prato                     ASC,
       cpf_cliente                    ASC
);


ALTER TABLE DELIVERY
       ADD PRIMARY KEY (nome_prato, cpf_cliente);


CREATE TABLE DESPESA (
       tipo_despesa         VARCHAR(100) NOT NULL,
       data_cobranca        DATE NOT NULL,
       valor_despesa        DECIMAL(8, 2)
);

CREATE UNIQUE INDEX XPKDESPESA ON DESPESA
(
       tipo_despesa                   ASC,
       data_cobranca                  ASC
);


ALTER TABLE DESPESA
       ADD PRIMARY KEY (tipo_despesa, data_cobranca);


CREATE TABLE FORNECEDOR (
       razao_social         VARCHAR(100),
       cnpj                 VARCHAR(14) NOT NULL,
       endereco_fornecedo   VARCHAR(100),
       telefone_fornecedo   VARCHAR(15),
       email_fornecedor     VARCHAR(100)
);

CREATE UNIQUE INDEX XPKFORNECEDOR ON FORNECEDOR
(
       cnpj                           ASC
);


ALTER TABLE FORNECEDOR
       ADD PRIMARY KEY (cnpj);


CREATE TABLE FUNCIONARIO (
       cpf_funcionario      VARCHAR(11) NOT NULL,
       nome_funcionario     VARCHAR(100),
       valor_salario        DECIMAL(8, 2),
       endereco_funcionar   VARCHAR(100),
       email_funcionario    VARCHAR(100),
       telefone_funcionar   VARCHAR(13),
       tipo_funcionario     VARCHAR(100),
       regime_trabalho      INTEGER,
       dia_pagamento        INTEGER
);

CREATE UNIQUE INDEX XPKFUNCIONARIO ON FUNCIONARIO
(
       cpf_funcionario                ASC
);


ALTER TABLE FUNCIONARIO
       ADD PRIMARY KEY (cpf_funcionario);


CREATE TABLE GARCOM (
       nota_avaliacao       DECIMAL(3, 1)
);


CREATE TABLE GERENTE (
       senha                CHAR(18)
);


CREATE TABLE INGREDIENTE (
       preco_ingrediente    DECIMAL(6, 2),
       nome_produto         VARCHAR(100) NOT NULL,
       data_compra          TIMESTAMP,
       qtde_comprada        INTEGER,
       cnpj                 VARCHAR(14) NOT NULL
);

CREATE UNIQUE INDEX XPKINGREDIENTE ON INGREDIENTE
(
       cnpj                           ASC,
       nome_produto                   ASC
);


ALTER TABLE INGREDIENTE
       ADD PRIMARY KEY (cnpj, nome_produto);


CREATE TABLE MESA (
       num_mesa             INTEGER NOT NULL,
       qtde_max_pessoas     INTEGER NOT NULL
);

CREATE UNIQUE INDEX XPKMESA ON MESA
(
       num_mesa                       ASC
);


ALTER TABLE MESA
       ADD PRIMARY KEY (num_mesa);


CREATE TABLE PEDIDO (
       qtde_pratos          INTEGER,
       data_pedido          TIMESTAMP,
       num_mesa             INTEGER NOT NULL,
       nome_prato           VARCHAR(50) NOT NULL,
       descricao_cupom      VARCHAR(50)
);

CREATE UNIQUE INDEX XPKPEDIDO ON PEDIDO
(
       num_mesa                       ASC,
       nome_prato                     ASC
);


ALTER TABLE PEDIDO
       ADD PRIMARY KEY (num_mesa, nome_prato);


CREATE TABLE PRATO (
       nome_prato           VARCHAR(50) NOT NULL,
       num_prato            INTEGER,
       tipo_prato           VARCHAR(50),
       preco_prato          DECIMAL(6, 2),
       pais_origem          VARCHAR(50)
);

CREATE UNIQUE INDEX XPKPRATO ON PRATO
(
       nome_prato                     ASC
);


ALTER TABLE PRATO
       ADD PRIMARY KEY (nome_prato);


CREATE TABLE RECEITA (
       qtde_ingredientes    INTEGER,
       nome_prato           VARCHAR(50) NOT NULL,
       cnpj                 VARCHAR(14) NOT NULL,
       nome_produto         VARCHAR(100) NOT NULL
);

CREATE UNIQUE INDEX XPKRECEITA ON RECEITA
(
       nome_prato                     ASC,
       cnpj                           ASC,
       nome_produto                   ASC
);


ALTER TABLE RECEITA
       ADD PRIMARY KEY (nome_prato, cnpj, nome_produto);


ALTER TABLE DELIVERY
       ADD FOREIGN KEY (descricao_cupom)
                             REFERENCES CUPOM
                             ON DELETE SET NULL;


ALTER TABLE DELIVERY
       ADD FOREIGN KEY (cpf_cliente)
                             REFERENCES CLIENTE
                             ON DELETE RESTRICT;


ALTER TABLE DELIVERY
       ADD FOREIGN KEY (nome_prato)
                             REFERENCES PRATO
                             ON DELETE RESTRICT;


ALTER TABLE INGREDIENTE
       ADD FOREIGN KEY (cnpj)
                             REFERENCES FORNECEDOR
                             ON DELETE RESTRICT;


ALTER TABLE PEDIDO
       ADD FOREIGN KEY (descricao_cupom)
                             REFERENCES CUPOM
                             ON DELETE SET NULL;


ALTER TABLE PEDIDO
       ADD FOREIGN KEY (nome_prato)
                             REFERENCES PRATO
                             ON DELETE RESTRICT;


ALTER TABLE PEDIDO
       ADD FOREIGN KEY (num_mesa)
                             REFERENCES MESA
                             ON DELETE RESTRICT;


ALTER TABLE RECEITA
       ADD FOREIGN KEY (cnpj, nome_produto)
                             REFERENCES INGREDIENTE
                             ON DELETE RESTRICT;


ALTER TABLE RECEITA
       ADD FOREIGN KEY (nome_prato)
                             REFERENCES PRATO
                             ON DELETE RESTRICT;




create trigger tD_CLIENTE after DELETE on CLIENTE
   REFERENCING OLD AS OLD for each row mode db2sql
   WHEN (0 < (select count(*) from DELIVERY where DELIVERY.cpf_cliente 
= old.cpf_cliente))
 BEGIN ATOMIC
     SIGNAL SQLSTATE '75001' ('Cannot DELETE CLIENTE because DELIVERY 
exists.');
 END
 !!

create trigger tU_CLIENTE after UPDATE on CLIENTE
     for each row mode db2sql
   WHEN (0 < ((select count(*) from CLIENTE where CLIENTE.cpf_cliente 
<> old.cpf_cliente)) AND
     (0 < (select count(*) from DELIVERY where DELIVERY.cpf_cliente = 
old.cpf_cliente)))
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE CLIENTE because DELIVERY 
exists.');
 END
 !!

create trigger tD_CUPOM after DELETE on CUPOM
   REFERENCING OLD AS OLD for each row mode db2sql
    update DELIVERY
      set
        descricao_cupom = NULL
      where
        DELIVERY.descricao_cupom = old.descricao_cupom
 !!

create trigger tD_CUPOM2 after DELETE on CUPOM
   REFERENCING OLD AS OLD for each row mode db2sql
    update PEDIDO
      set
        descricao_cupom = NULL
      where
        PEDIDO.descricao_cupom = old.descricao_cupom
 !!

create trigger tU_CUPOM after UPDATE on CUPOM
     for each row mode db2sql
   WHEN (0 < (select count(*) from CUPOM where CUPOM.descricao_cupom <> 
old.descricao_cupom))
     update DELIVERY
       set
         descricao_cupom = NULL
       where
         DELIVERY.descricao_cupom = old.descricao_cupom
 !!

create trigger tU_CUPOM2 after UPDATE on CUPOM
     for each row mode db2sql
   WHEN (0 < (select count(*) from CUPOM where CUPOM.descricao_cupom <> 
old.descricao_cupom))
     update PEDIDO
       set
         descricao_cupom = NULL
       where
         PEDIDO.descricao_cupom = old.descricao_cupom
 !!

create trigger tI_DELIVERY after INSERT on DELIVERY
   REFERENCING NEW AS NEW for each row mode db2sql
    update DELIVERY
      set
        descricao_cupom = NULL
      where
        not exists (
          select * from CUPOM
            where
              new.descricao_cupom = CUPOM.descricao_cupom
        )
 !!

create trigger tI_DELIVERY2 after INSERT on DELIVERY
   REFERENCING NEW AS NEW for each row mode db2sql
   WHEN ((0 = (select count(*) from CLIENTE where new.cpf_cliente = 
CLIENTE.cpf_cliente))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot INSERT DELIVERY because CLIENTE 
does not exist.');
 END
 !!

create trigger tI_DELIVERY3 after INSERT on DELIVERY
   REFERENCING NEW AS NEW for each row mode db2sql
   WHEN ((0 = (select count(*) from PRATO where new.nome_prato = 
PRATO.nome_prato))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot INSERT DELIVERY because PRATO 
does not exist.');
 END
 !!

create trigger tU_DELIVERY after UPDATE on DELIVERY
     for each row mode db2sql
    update DELIVERY
      set
        descricao_cupom = NULL
      where
        not exists (
          select * from CUPOM
            where
              new.descricao_cupom = CUPOM.descricao_cupom
        ) 
 !!

create trigger tU_DELIVERY2 after UPDATE on DELIVERY
     for each row mode db2sql
   WHEN (0 = ((select count(*) from CLIENTE where new.cpf_cliente = 
CLIENTE.cpf_cliente))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE DELIVERY because CLIENTE 
does not exist.');
 END
 !!

create trigger tU_DELIVERY3 after UPDATE on DELIVERY
     for each row mode db2sql
   WHEN (0 = ((select count(*) from PRATO where new.nome_prato = 
PRATO.nome_prato))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE DELIVERY because PRATO 
does not exist.');
 END
 !!

create trigger tD_FORNECEDOR after DELETE on FORNECEDOR
   REFERENCING OLD AS OLD for each row mode db2sql
   WHEN (0 < (select count(*) from INGREDIENTE where INGREDIENTE.cnpj = 
old.cnpj))
 BEGIN ATOMIC
     SIGNAL SQLSTATE '75001' ('Cannot DELETE FORNECEDOR because 
INGREDIENTE exists.');
 END
 !!

create trigger tU_FORNECEDOR after UPDATE on FORNECEDOR
     for each row mode db2sql
   WHEN (0 < ((select count(*) from FORNECEDOR where FORNECEDOR.cnpj <> 
old.cnpj)) AND
     (0 < (select count(*) from INGREDIENTE where INGREDIENTE.cnpj = 
old.cnpj)))
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE FORNECEDOR because 
INGREDIENTE exists.');
 END
 !!

create trigger tD_INGREDIENTE after DELETE on INGREDIENTE
   REFERENCING OLD AS OLD for each row mode db2sql
   WHEN (0 < (select count(*) from RECEITA where RECEITA.cnpj = 
old.cnpj and
                                                 RECEITA.nome_produto = 
old.nome_produto))
 BEGIN ATOMIC
     SIGNAL SQLSTATE '75001' ('Cannot DELETE INGREDIENTE because 
RECEITA exists.');
 END
 !!

create trigger tI_INGREDIENTE after INSERT on INGREDIENTE
   REFERENCING NEW AS NEW for each row mode db2sql
   WHEN ((0 = (select count(*) from FORNECEDOR where new.cnpj = 
FORNECEDOR.cnpj))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot INSERT INGREDIENTE because 
FORNECEDOR does not exist.');
 END
 !!

create trigger tU_INGREDIENTE after UPDATE on INGREDIENTE
     for each row mode db2sql
   WHEN (0 < ((select count(*) from INGREDIENTE where INGREDIENTE.cnpj 
<> old.cnpj or 
                                                      
INGREDIENTE.nome_produto <> old.nome_produto)) AND
     (0 < (select count(*) from RECEITA where RECEITA.cnpj = old.cnpj 
and
                                              RECEITA.nome_produto = 
old.nome_produto)))
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE INGREDIENTE because 
RECEITA exists.');
 END
 !!

create trigger tU_INGREDIENTE2 after UPDATE on INGREDIENTE
     for each row mode db2sql
   WHEN (0 = ((select count(*) from FORNECEDOR where new.cnpj = 
FORNECEDOR.cnpj))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE INGREDIENTE because 
FORNECEDOR does not exist.');
 END
 !!

create trigger tD_MESA after DELETE on MESA
   REFERENCING OLD AS OLD for each row mode db2sql
   WHEN (0 < (select count(*) from PEDIDO where PEDIDO.num_mesa = 
old.num_mesa))
 BEGIN ATOMIC
     SIGNAL SQLSTATE '75001' ('Cannot DELETE MESA because PEDIDO 
exists.');
 END
 !!

create trigger tU_MESA after UPDATE on MESA
     for each row mode db2sql
   WHEN (0 < ((select count(*) from MESA where MESA.num_mesa <> 
old.num_mesa)) AND
     (0 < (select count(*) from PEDIDO where PEDIDO.num_mesa = 
old.num_mesa)))
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE MESA because PEDIDO 
exists.');
 END
 !!

create trigger tI_PEDIDO after INSERT on PEDIDO
   REFERENCING NEW AS NEW for each row mode db2sql
    update PEDIDO
      set
        descricao_cupom = NULL
      where
        not exists (
          select * from CUPOM
            where
              new.descricao_cupom = CUPOM.descricao_cupom
        )
 !!

create trigger tI_PEDIDO2 after INSERT on PEDIDO
   REFERENCING NEW AS NEW for each row mode db2sql
   WHEN ((0 = (select count(*) from PRATO where new.nome_prato = 
PRATO.nome_prato))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot INSERT PEDIDO because PRATO 
does not exist.');
 END
 !!

create trigger tI_PEDIDO3 after INSERT on PEDIDO
   REFERENCING NEW AS NEW for each row mode db2sql
   WHEN ((0 = (select count(*) from MESA where new.num_mesa = 
MESA.num_mesa))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot INSERT PEDIDO because MESA does 
not exist.');
 END
 !!

create trigger tU_PEDIDO after UPDATE on PEDIDO
     for each row mode db2sql
    update PEDIDO
      set
        descricao_cupom = NULL
      where
        not exists (
          select * from CUPOM
            where
              new.descricao_cupom = CUPOM.descricao_cupom
        ) 
 !!

create trigger tU_PEDIDO2 after UPDATE on PEDIDO
     for each row mode db2sql
   WHEN (0 = ((select count(*) from PRATO where new.nome_prato = 
PRATO.nome_prato))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE PEDIDO because PRATO 
does not exist.');
 END
 !!

create trigger tU_PEDIDO3 after UPDATE on PEDIDO
     for each row mode db2sql
   WHEN (0 = ((select count(*) from MESA where new.num_mesa = 
MESA.num_mesa))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE PEDIDO because MESA does 
not exist.');
 END
 !!

create trigger tD_PRATO after DELETE on PRATO
   REFERENCING OLD AS OLD for each row mode db2sql
   WHEN (0 < (select count(*) from DELIVERY where DELIVERY.nome_prato = 
old.nome_prato))
 BEGIN ATOMIC
     SIGNAL SQLSTATE '75001' ('Cannot DELETE PRATO because DELIVERY 
exists.');
 END
 !!

create trigger tD_PRATO2 after DELETE on PRATO
   REFERENCING OLD AS OLD for each row mode db2sql
   WHEN (0 < (select count(*) from PEDIDO where PEDIDO.nome_prato = 
old.nome_prato))
 BEGIN ATOMIC
     SIGNAL SQLSTATE '75001' ('Cannot DELETE PRATO because PEDIDO 
exists.');
 END
 !!

create trigger tD_PRATO3 after DELETE on PRATO
   REFERENCING OLD AS OLD for each row mode db2sql
   WHEN (0 < (select count(*) from RECEITA where RECEITA.nome_prato = 
old.nome_prato))
 BEGIN ATOMIC
     SIGNAL SQLSTATE '75001' ('Cannot DELETE PRATO because RECEITA 
exists.');
 END
 !!

create trigger tU_PRATO after UPDATE on PRATO
     for each row mode db2sql
   WHEN (0 < ((select count(*) from PRATO where PRATO.nome_prato <> 
old.nome_prato)) AND
     (0 < (select count(*) from DELIVERY where DELIVERY.nome_prato = 
old.nome_prato)))
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE PRATO because DELIVERY 
exists.');
 END
 !!

create trigger tU_PRATO2 after UPDATE on PRATO
     for each row mode db2sql
   WHEN (0 < ((select count(*) from PRATO where PRATO.nome_prato <> 
old.nome_prato)) AND
     (0 < (select count(*) from PEDIDO where PEDIDO.nome_prato = 
old.nome_prato)))
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE PRATO because PEDIDO 
exists.');
 END
 !!

create trigger tU_PRATO3 after UPDATE on PRATO
     for each row mode db2sql
   WHEN (0 < ((select count(*) from PRATO where PRATO.nome_prato <> 
old.nome_prato)) AND
     (0 < (select count(*) from RECEITA where RECEITA.nome_prato = 
old.nome_prato)))
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE PRATO because RECEITA 
exists.');
 END
 !!

create trigger tI_RECEITA after INSERT on RECEITA
   REFERENCING NEW AS NEW for each row mode db2sql
   WHEN ((0 = (select count(*) from INGREDIENTE where new.cnpj = 
INGREDIENTE.cnpj and
                                                      new.nome_produto 
= INGREDIENTE.nome_produto))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot INSERT RECEITA because 
INGREDIENTE does not exist.');
 END
 !!

create trigger tI_RECEITA2 after INSERT on RECEITA
   REFERENCING NEW AS NEW for each row mode db2sql
   WHEN ((0 = (select count(*) from PRATO where new.nome_prato = 
PRATO.nome_prato))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot INSERT RECEITA because PRATO 
does not exist.');
 END
 !!

create trigger tU_RECEITA after UPDATE on RECEITA
     for each row mode db2sql
   WHEN (0 = ((select count(*) from INGREDIENTE where new.cnpj = 
INGREDIENTE.cnpj and
                                                      new.nome_produto 
= INGREDIENTE.nome_produto))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE RECEITA because 
INGREDIENTE does not exist.');
 END
 !!

create trigger tU_RECEITA2 after UPDATE on RECEITA
     for each row mode db2sql
   WHEN (0 = ((select count(*) from PRATO where new.nome_prato = 
PRATO.nome_prato))
     )
 BEGIN ATOMIC
       SIGNAL SQLSTATE '75001' ('Cannot UPDATE RECEITA because PRATO 
does not exist.');
 END
 !!

