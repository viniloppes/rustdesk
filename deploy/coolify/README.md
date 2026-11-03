# RustDesk no Coolify

O Compose sobe o servidor de IDs (`hbbs`), o relay (`hbbr`) e o download HTTPS. O build baixa o RustDesk oficial para Windows x64 e verifica o SHA-256. No deploy, a chave pública gerada pelo servidor é usada para montar o executável portátil com o endereço já configurado. A chave privada e o banco ficam no volume `server-data`.

## Configuração no Coolify

1. No DNS, aponte `rustdesk.amberlink.com.br` ou o domínio escolhido para o IP público do servidor Linux. Use DNS direto para o host do RustDesk. No Cloudflare, use **DNS only** para esse registro.
2. Libere **21115–21117 TCP** e **21116 UDP** no firewall do servidor e no firewall do provedor, se houver. Para o HTTPS, o proxy do Coolify precisa receber **80/443 TCP**.
3. Crie uma aplicação **Public Repository** com `https://github.com/viniloppes/rustdesk` e a branch `deploy/rustdesk-coolify`. Selecione **Docker Compose**, base directory `/deploy/coolify` e Docker Compose location `/compose.yaml`.
4. Em **Environment Variables**, configure `RUSTDESK_HOST` com o domínio do passo 1, sem protocolo nem porta. Ajuste os nomes se quiser.
5. Em **Domains**, vincule apenas o serviço `download` ao domínio HTTPS, incluindo a porta interna. Exemplo de valor no painel `https://rustdesk.amberlink.com.br:8080`.
6. Faça o deploy. O serviço `public-key` é uma etapa de inicialização e termina com código 0 após copiar a chave. O link público fica em `https://rustdesk.amberlink.com.br/windows`, sem a porta interna.

| Variável | Valor inicial ou exemplo | O que controla |
| --- | --- | --- |
| `RUSTDESK_HOST` | `rustdesk.amberlink.com.br` | Domínio do servidor de IDs e relay. Até 63 caracteres. |
| `WINDOWS_FILENAME` | `Amberlink-Suporte.exe` | Nome do download. Use letras ASCII, números, hífen ou sublinhado, com extensão `.exe`. |
| `WINDOWS_PRODUCT_NAME` | `Amberlink Suporte` | Nome e descrição nas propriedades do executável externo. Aceita espaços e os mesmos caracteres do nome de arquivo. |

## Verificação

- Rode `curl -fI https://rustdesk.amberlink.com.br/windows` e confira HTTP 200 e o nome no cabeçalho `Content-Disposition`.
- Baixe e abra o arquivo em dois Windows x64 com perfil limpo, de redes diferentes. Em ambos, confirme o status **Pronto** e teste uma conexão remota. Para conferir especificamente o relay, use a opção de forçar relay no cliente durante o teste.
- Se já houver RustDesk configurado, feche a instância existente e confira **Configurações → Rede**. Uma configuração anterior pode ter precedência. Para fazer o teste com o portátil em um Windows que já usa RustDesk, prefira um perfil limpo ou uma VM.
- A janela do cliente usa a marca RustDesk. O executável externo é gerado sem assinatura própria e o Windows pode mostrar um aviso do SmartScreen. Para nome, ícone e logo dentro do aplicativo, consulte o [gerador oficial de clientes personalizados](https://rustdesk.com/docs/en/self-host/client-configuration/#1-custom-client-generator-pro-only-basic-plan-or-custom-plan).

Mantenha backup do volume `server-data` para preservar a chave e o banco ao migrar o serviço. Se trocar a chave ou o domínio, redeploye e distribua o download atualizado.

[Cliente oficial e código-fonte da versão empacotada](https://github.com/rustdesk/rustdesk/releases/tag/1.5.1)
