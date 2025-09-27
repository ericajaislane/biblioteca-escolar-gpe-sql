-- 1. Cria o banco de dados 
CREATE DATABASE IF NOT EXISTS biblioteca_escolar_gpe;
USE biblioteca_escolar_gpe;

-- Desativa temporariamente a checagem de chaves estrangeiras para permitir a criação e inserção de dados
SET FOREIGN_KEY_CHECKS = 0;

-- LIMPEZA: Remove tabelas existentes (em ordem reversa de dependência) para garantir uma execução limpa e evitar erros de chave duplicada
DROP TABLE IF EXISTS Emprestimo;
DROP TABLE IF EXISTS Autoria;
DROP TABLE IF EXISTS Livro;
DROP TABLE IF EXISTS Titulo;
DROP TABLE IF EXISTS Aluno;
DROP TABLE IF EXISTS Autor;
DROP TABLE IF EXISTS Pessoa;
DROP TABLE IF EXISTS Curso;
DROP TABLE IF EXISTS Editora;
DROP TABLE IF EXISTS Municipio;

-- CRIAÇÃO DAS TABELAS (CREATE TABLE)

-- Tabela 1: Municipio
CREATE TABLE IF NOT EXISTS Municipio (
cod_municipio INT PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
estado CHAR(2) NOT NULL
);

-- Tabela 2: Pessoa (Entidade base: CPF é a PK)
CREATE TABLE IF NOT EXISTS Pessoa (
CPF VARCHAR(11) PRIMARY KEY,
nome_completo VARCHAR(150) NOT NULL,
data_nascimento DATE
);

-- Tabela 3: Autor (Especialização de Pessoa)
CREATE TABLE IF NOT EXISTS Autor (
CPF_Autor VARCHAR(11) PRIMARY KEY,
nacionalidade VARCHAR(50),

FOREIGN KEY (CPF_Autor) REFERENCES Pessoa(CPF)
ON DELETE CASCADE
ON UPDATE CASCADE

);

-- Tabela 4: Editora
CREATE TABLE IF NOT EXISTS Editora (
cod_editora INT PRIMARY KEY AUTO_INCREMENT,
nome_fantasia VARCHAR(100) NOT NULL UNIQUE,
telefone VARCHAR(20)
);

-- Tabela 5: Curso
CREATE TABLE IF NOT EXISTS Curso (
cod_curso INT PRIMARY KEY,
nome_curso VARCHAR(100) NOT NULL,
duracao_semestres INT
);

-- Tabela 6: Aluno (Especialização de Pessoa + FKs)
CREATE TABLE IF NOT EXISTS Aluno (
CPF_Aluno VARCHAR(11) PRIMARY KEY,
registro_academico VARCHAR(20) NOT NULL UNIQUE,
fk_cod_municipio INT NOT NULL,
fk_cod_curso INT NOT NULL,

FOREIGN KEY (CPF_Aluno) REFERENCES Pessoa(CPF)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (fk_cod_municipio) REFERENCES Municipio(cod_municipio),
FOREIGN KEY (fk_cod_curso) REFERENCES Curso(cod_curso)

);

-- Tabela 7: Titulo (A obra conceitual, FK para Editora)
CREATE TABLE IF NOT EXISTS Titulo (
cod_titulo INT PRIMARY KEY AUTO_INCREMENT,
titulo_obra VARCHAR(255) NOT NULL,
ano_publicacao YEAR,
fk_cod_editora INT NOT NULL,

FOREIGN KEY (fk_cod_editora) REFERENCES Editora(cod_editora)
);

-- Tabela 8: Livro (O exemplar físico, FK para Título)
CREATE TABLE IF NOT EXISTS Livro (
cod_livro INT PRIMARY KEY AUTO_INCREMENT,
status_livro ENUM('Disponível', 'Emprestado', 'Manutenção') NOT NULL,
fk_cod_titulo INT NOT NULL,

FOREIGN KEY (fk_cod_titulo) REFERENCES Titulo(cod_titulo)

);

-- Tabela 9: Autoria (Tabela Associativa N:N entre Autor e Título)
CREATE TABLE IF NOT EXISTS Autoria (
fk_CPF_Autor VARCHAR(11),
fk_cod_titulo INT,

-- Chave Primária Composta
PRIMARY KEY (fk_CPF_Autor, fk_cod_titulo),

FOREIGN KEY (fk_CPF_Autor) REFERENCES Autor(CPF_Autor),
FOREIGN KEY (fk_cod_titulo) REFERENCES Titulo(cod_titulo)

);
-- Tabela 10: Emprestimo (Relacionamento entre Livro e Aluno)
CREATE TABLE IF NOT EXISTS Emprestimo (
cod_emprestimo INT PRIMARY KEY AUTO_INCREMENT,
data_saida DATE NOT NULL,
data_prevista_devolucao DATE NOT NULL,
fk_CPF_Aluno VARCHAR(11) NOT NULL,
fk_cod_livro INT NOT NULL UNIQUE, -- Garante que o livro está emprestado 1:1

FOREIGN KEY (fk_CPF_Aluno) REFERENCES Aluno(CPF_Aluno),
FOREIGN KEY (fk_cod_livro) REFERENCES Livro(cod_livro)

);

-- INSERÇÃO DE DADOS (INSERT INTO) - 3 registros em todas as 10 tabelas

-- 1. Municipio
INSERT INTO Municipio (cod_municipio, nome, estado) VALUES
(100, 'Rio de Janeiro', 'RJ'),
(200, 'Belo Horizonte', 'MG'),
(300, 'Curitiba', 'PR');

-- 2. Pessoa (3 Alunos e 2 Autores, total 5)
INSERT INTO Pessoa (CPF, nome_completo, data_nascimento) VALUES
('11122233344', 'Paula Oliveira Santos', '2004-03-15'),
('55566677788', 'Gabriel Lima Costa', '2003-09-20'),
('99900011122', 'Sofia Rodrigues Melo', '2005-01-28'),
('44455566677', 'Ana Maria Souza', '1980-08-10'),
('88899900011', 'Pedro Henrique Dias', '1975-04-19');

-- 3. Autor (Referencia Pessoa)
INSERT INTO Autor (CPF_Autor, nacionalidade) VALUES
('44455566677', 'Brasileira'),
('88899900011', 'Brasileira'),
('11122233344', 'Portuguesa'); -- Exemplo de Aluno que também é Autor

-- 4. Editora
INSERT INTO Editora (cod_editora, nome_fantasia, telefone) VALUES
(1, 'Editora Águia', '2133334444'),
(2, 'Conhecimento Livre', '3155556666'),
(3, 'Templo da Ciência', '4177778888');

-- 5. Curso
INSERT INTO Curso (cod_curso, nome_curso, duracao_semestres) VALUES
(10, 'Administração', 8),
(20, 'Medicina', 12),
(30, 'Ciência da Computação', 8);

-- 6. Aluno (Referencia Pessoa, Município, Curso)
INSERT INTO Aluno (CPF_Aluno, registro_academico, fk_cod_municipio, fk_cod_curso) VALUES
('11122233344', '20241001', 100, 10),
('55566677788', '20241002', 200, 20),
('99900011122', '20241003', 300, 30);

-- 7. Titulo (Referencia Editora)
-- CORREÇÃO: Dividindo a inserção multi-linha em comandos separados para garantir o uso correto de LAST_INSERT_ID()
INSERT INTO Titulo (titulo_obra, ano_publicacao, fk_cod_editora) VALUES
('Gestão Estratégica Moderna', 2023, 1);
SET @titulo1 = LAST_INSERT_ID();

INSERT INTO Titulo (titulo_obra, ano_publicacao, fk_cod_editora) VALUES
('Anatomia Humana Essencial', 2021, 2);
SET @titulo2 = LAST_INSERT_ID();

INSERT INTO Titulo (titulo_obra, ano_publicacao, fk_cod_editora) VALUES
('Redes de Computadores: O Guia', 2024, 3);
SET @titulo3 = LAST_INSERT_ID();

-- 8. Livro (Referencia Título)
INSERT INTO Livro (status_livro, fk_cod_titulo) VALUES
('Disponível', @titulo1), -- Livro 1 é cópia do Título 1
('Emprestado', @titulo1), -- Livro 2 é cópia do Título 1 e será emprestado
('Disponível', @titulo2), -- Livro 3 é cópia do Título 2
('Emprestado', @titulo3); -- Livro 4 é cópia do Título 3 e será emprestado

-- 9. Autoria (Referencia Autor e Título)
INSERT INTO Autoria (fk_CPF_Autor, fk_cod_titulo) VALUES
('44455566677', @titulo1), -- Autor 1 escreveu Título 1
('88899900011', @titulo2), -- Autor 2 escreveu Título 2
('44455566677', @titulo3); -- Autor 1 escreveu Título 3

-- 10. Emprestimo (Relacionamento entre Livro e Aluno - Os Livros 2 e 4 estão sendo emprestados)
-- Nota: O Livro 3 estava 'Disponível' no passo 8, mas será emprestado aqui.
INSERT INTO Emprestimo (data_saida, data_prevista_devolucao, fk_CPF_Aluno, fk_cod_livro) VALUES
('2025-09-25', '2025-10-05', '11122233344', 2), -- Livro 2 (Cópia de Gestão) emprestado para Aluno 1
('2025-09-26', '2025-10-06', '55566677788', 3), -- Livro 3 (Cópia de Anatomia) emprestado para Aluno 2
('2025-09-27', '2025-10-07', '99900011122', 4); -- Livro 4 (Cópia de Redes) emprestado para Aluno 3

-- Reativa a checagem de chaves estrangeiras
SET FOREIGN_KEY_CHECKS = 1;