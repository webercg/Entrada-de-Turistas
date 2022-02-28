CREATE TABLE pais (
	cod_pais_origem INTEGER  NOT NULL,
	nome_pais_origem VARCHAR(50) NOT NULL,	
	continente VARCHAR(50) NOT NULL,
	idh NUMERIC(11, 2) NOT NULL, 
	CONSTRAINT  cod_pais_origem_pk PRIMARY KEY(cod_pais_origem),
	CONSTRAINT idh_positivo_check CHECK (idh > 0)
);

--criação da tabela turista
CREATE TABLE turista (
	num_passaporte VARCHAR(50) NOT NULL, 
	nome VARCHAR(50) NOT NULL,
	estado_civil CHAR,
	sexo CHAR,
	datanascimento DATE NOT NULL,
	cod_pais_origem INTEGER  NOT NULL, -- chave estrangeira
	CONSTRAINT num_passaporte_pk PRIMARY KEY(num_passaporte),
	CONSTRAINT sexo_check CHECK (sexo IN ('M', 'F', 'N')),
	CONSTRAINT cod_pais_origem_fk FOREIGN KEY (cod_pais_origem) 
			REFERENCES pais(cod_pais_origem),
	CONSTRAINT estado_civil_check CHECK (estado_civil IN ('S', 'C', 'D/S','V'))-- solteiro,casado,divorciado,separado,viuvo
);

--criação da estado brasileiro
CREATE TABLE estado_brasileiro (
	cod_uf INTEGER NOT NULL,
	regiao VARCHAR(50) NOT NULL,
	nome_estado VARCHAR(50) NOT NULL,
	CONSTRAINT cod_uf_pk PRIMARY KEY(cod_uf)
);

--criação da tabela viagem
CREATE TABLE viagem(
	id_viagem INTEGER NOT NULL,
	data_chegada DATE NOT NULL,
	pais_origem VARCHAR(50) NOT NULL,
	continente_origem VARCHAR(50) NOT NULL,
	num_passaporte VARCHAR(100) NOT NULL, 
	cod_uf INTEGER NOT NULL,
	via VARCHAR(10) NOT NULL,
	CONSTRAINT id_viagem_pk PRIMARY KEY(id_viagem),
	CONSTRAINT num_passaporte_fk FOREIGN KEY (num_passaporte) 
		REFERENCES turista(num_passaporte),
	CONSTRAINT cod_uf_fk FOREIGN KEY (cod_uf) 
		REFERENCES estado_brasileiro(cod_uf),
	CONSTRAINT via_check CHECK (via IN ('Aérea', 'Fluvial', 'Marítima', 'Terrestre'))
);