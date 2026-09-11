# RPA Atri

Este projeto esta sendo reorganizado para sair de uma automacao baseada em tela e evoluir para um produto orientado por API, com tres etapas:

1. Consolidacao das OSs.
2. Portal de batimento humano e validacoes complementares em seguradoras.
3. Fechamento das OSs no Conference via API.

## Estado atual

O fluxo principal usa a arquitetura orientada por API, sem a antiga automacao de tela do Conference.

## Passo 1

O novo Passo 1 ja possui uma estrutura inicial para:

- listar OSs retornadas pelo client do Conference;
- buscar dados da OS;
- baixar documentos obrigatorios;
- ler orcamento e termo de quitacao com Gemini;
- validar anexos, CNPJ, termo e orcamento;
- gravar o resultado em banco SQLite.

Enquanto a API real do Conference nao estiver disponivel, o client temporario le o arquivo `os.csv`.

Execucao:

```bash
python -m apps.passo_1_consolidacao.main
```

Banco gerado:

```text
data/consolidacao.db
```

A API de triagem do Passo 1 grava os resultados no MySQL configurado em
`DATABASE_URL` e no Redis configurado em `REDIS_URL`.

```bash
export DATABASE_URL="mysql://usuario:senha@host:3306/rpa_oficinas"
export REDIS_URL="redis://usuario:senha@host:6379/0"
```

## Passo 3

O Passo 3 esta preparado como contrato inicial em `steps/passo_3_fechamento`, aguardando a API real de fechamento do Conference.

## Gemini / Vertex AI

O modelo padrao para leitura de documentos e prints e `gemini-2.5-flash`.

Variaveis opcionais:

```bash
export GEMINI_MODEL="gemini-2.5-flash"
export VERTEX_AI_PROJECT="zamba-cb2ab"
export VERTEX_AI_LOCATION="us-central1"
```

## Prisma

O Prisma foi configurado para modelar o banco de desenvolvimento MySQL.

Arquivos principais:

- `prisma/schema.prisma`
- `package.json`
- `package-lock.json`

Comandos:

```bash
npm run prisma:validate
npm run prisma:generate
npm run prisma:push
npm run prisma:studio
```

Observacao sobre o `.env`: se a senha do banco tiver caracteres especiais como `@`, eles precisam estar escapados na URL. Exemplo: `@` vira `%40`.

No estado atual, o Prisma valida o schema e gera o client, mas o `db push` depende de permissao do usuario informado no banco configurado.



curl -X POST 'https://conference.atri.com.br/integra/ws.php' \
  -H 'acao: consultar_sinistros_registros' \
  -H 'token: TOKEN_PADRAO' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: curl/7.68.0' \
  --data-urlencode 'filtro=O' \
  --data-urlencode 'tipo_data=1' \
  --data-urlencode 'status=5' \
  --data-urlencode 'data_inicial=10/03/2026' \
  --data-urlencode 'data_final=11/06/2026'
