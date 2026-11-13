# VORZIX STUDIO

Site de links inspirado na referência enviada, com identidade visual preta, botões cinza arredondados e painel administrativo integrado ao Supabase.

## Arquivos
- `index.html`: site público + login + painel administrativo.
- `supabase.sql`: tabelas, políticas de segurança (RLS) e bucket de imagens.
- `assets/vorzix-logo.jpg`: recorte da logo da referência enviada, usado inicialmente no site.

## Configuração

1. Crie um projeto no Supabase.
2. Abra **SQL Editor**, cole o conteúdo de `supabase.sql` e execute.
3. Em **Authentication > Users**, crie o usuário administrador com o e-mail desejado e uma senha forte. Não disponibilize cadastro público.
4. Copie o UUID desse usuário e execute no SQL Editor:
   ```sql
   insert into public.admin_users (user_id)
   values ('COLE_O_UUID_DO_USUARIO_AQUI');
   ```
5. Em **Project Settings > API**, copie a Project URL e a chave `anon`/publishable.
6. Abra `index.html` e substitua:
   - `COLE_AQUI_SUA_SUPABASE_URL`
   - `COLE_AQUI_SUA_SUPABASE_ANON_KEY`
7. Publique `index.html` no GitHub Pages, Vercel ou hospedagem estática.

## Como administrar
Acesse a página publicada e toque em **Área administrativa**. Entre com o e-mail e senha do usuário autorizado.

No painel é possível:
- Alterar título e descrição.
- Enviar ou remover a logo.
- Adicionar, editar e excluir botões.
- Enviar imagens para os botões.
- Ativar/desativar botões.
- Reordenar os botões.

As imagens ficam no bucket público `vorzix-assets`. O acesso de escrita é restrito pela política RLS aos usuários registrados em `admin_users`.

## Segurança
A chave `anon`/publishable é própria para uso no navegador quando as políticas RLS estão configuradas. **Nunca coloque a chave `service_role` no HTML.**
