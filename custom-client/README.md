# Cliente personalizado (AmberDesk) + servidor no Coolify

Objetivo: o usuário só baixa o `.exe` e usa. O cliente já vem apontando para o
seu servidor (ID/relay e chave) e com o seu nome.

## 1. DNS (Registro.br)

| Tipo | Nome       | Valor          |
|------|------------|----------------|
| A    | `rustdesk` | `136.248.88.0` |
| A    | `suporte`  | `136.248.88.0` |

`rustdesk.amberlink.com.br` é o servidor (o cliente fala com ele direto nas portas 21115-21119).
`suporte.amberlink.com.br` é a página de download (passa pelo Traefik do Coolify, com HTTPS).

## 2. Portas

No servidor (Terminal do Coolify ou SSH, como root):

    bash custom-client/server/open-ports.sh

Na Oracle Cloud, crie também as regras de entrada na Security List da VCN:
TCP 21115-21119 e UDP 21116, origem `0.0.0.0/0`.

## 3. Servidor no Coolify

1. Gere as chaves: `python3 custom-client/server/gen-keys.py`
2. Coolify > New Resource > Docker Compose, cole `custom-client/coolify/docker-compose.yml`.
3. Variáveis de ambiente: `RENDEZVOUS_SERVER=rustdesk.amberlink.com.br`, `RS_PUB_KEY`, `RS_PRIV_KEY`,
   `APP_NAME=AmberDesk` e `GITHUB_TOKEN`: token fine-grained do GitHub, só leitura (Contents: Read-only)
   no repositório privado `viniloppes/Rust-AmberDesk`. É com ele que a página baixa o `.exe` da release privada.
4. Domínio do serviço `download`: `https://suporte.amberlink.com.br`.
5. Deploy.

`ENCRYPTED_ONLY=1`: só conecta quem tem a chave pública, ou seja, os seus clientes.

## 4. Build do cliente

GitHub > Actions > **Custom client (Windows)** > Run workflow.

Os valores vêm dos campos do formulário ou das variáveis do repositório
(Settings > Secrets and variables > Actions > Variables):
`CUSTOM_APP_NAME`, `CUSTOM_APP_DESCRIPTION`, `CUSTOM_RENDEZVOUS_SERVER`, `CUSTOM_RS_PUB_KEY`.
Para um ícone próprio, coloque `custom-client/icon.ico`.

O build (cerca de 1h) publica `AmberDesk.exe` na release `custom-client` do repositório privado.
Depois, reinicie o container `download` no Coolify: ele baixa a versão nova com o token e passa a servi-la.
Enquanto não existe build próprio, a página serve o RustDesk oficial com o servidor
no nome do arquivo (`AmberDesk-host=...,key=...,.exe`), que também já conecta sozinho.

Link para mandar aos clientes: `https://suporte.amberlink.com.br`
(ou direto `https://suporte.amberlink.com.br/download`).
