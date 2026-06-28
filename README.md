## 1. Stack Tecnológica

* **Backend:** Delphi + Framework **Horse**.
* **Frontend:** Delphi **FMX (FireMonkey)** - Arquitetura Multiplataforma.
* **Comunicação:** REST JSON (via RESTClient ou NetHTTPClient).

## 2. Estrutura do Repositório

* `/src/Server`: API REST.
* `/src/Desktop`: Projeto multiplataforma (Windows/Android/iOS).
* `/src/Mobile`: Projeto mobile multiplataforma (Windows/Android/iOS).
* `/src/Comum`: Units e bibliotecas comuns no projeto.
* `/src/Gerencial`: Projeto do software gerencial (Clientes/licenças) multiplataforma (Windows/Android/iOS).
* `/src/Gerencial/web`: Projeto Web do software gerencial (Clientes/licenças).
* `/docs`: Especificações de telas e fluxos de navegação.

## 4. Como rodar o projeto

### Frontend (FMX)
1. Abra o arquivo `.dproj` na pasta `src/Desktop`.
2. Selecione a plataforma de destino (Windows 64-bit ou Android).
3. Compile e execute (F9).
*Nota: Certifique-se de que o endereço da API no arquivo de configuração (`config.ini` ou similar) aponta para o seu servidor Horse.*

## 5. Componentes de Terceiros

### Horse
1. Abra o terminal no diretório D:\Projetos\Intellisoft_ERP\src\Server e execute o comando BOSS INIT
2. No mesmo terminal e diretório, execute o comando boss install Horse
3. No mesmo terminal e diretório, execute o comando boss install Jhonson
4. No mesmo terminal e diretório, execute o comando boss install github.com/viniciussanchez/dataset-serialize
5. É necessário repetir os passo de 1 a 4 no diretório D:\Projetos\Intellisoft_ERP\src\Gerencial\Server para instalar o Horse na pasta do servidor do GIL

## 6. REFERÊNCIA DE MATERIAL PARA O DESIGN
* **Ícones:** https://pictogrammers.com/library/mdi/
