# 📚 Guia Completo: Publicar Projeto no Git

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Preparar o Repositório Local](#1-preparar-o-repositório-local)
3. [Criar Repositório no GitHub](#2-criar-repositório-no-github)
4. [Conectar Repositório Local ao GitHub](#3-conectar-repositório-local-ao-github)
5. [Fazer Primeiro Commit](#4-fazer-primeiro-commit)
6. [Enviar para o GitHub](#5-enviar-para-o-github)
7. [Atualizar README.md](#6-atualizar-readmemd)
8. [Commits Futuros](#7-commits-futuros)
9. [Segurança e Privacidade](#8-segurança-e-privacidade)
10. [Branches (Opcional)](#9-branches-opcional)
11. [Troubleshooting](#10-troubleshooting)

---

## 📋 Pré-requisitos

### 1. Conta no GitHub/GitLab/Bitbucket

**Recomendado: GitHub**
- Criar conta em: https://github.com
- É gratuito e amplamente usado
- Interface intuitiva
- Suporte a repositórios privados

**Alternativas:**
- **GitLab**: https://gitlab.com
- **Bitbucket**: https://bitbucket.org

### 2. Git Instalado

**Verificar se está instalado:**
```bash
git --version
```

**Se não estiver instalado:**
- **Windows**: https://git-scm.com/download/win
- Durante instalação, use as opções padrão
- Após instalar, reinicie o terminal

**Configurar Git (primeira vez):**
```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"
```

### 3. Projeto Limpo e Testado

Antes de publicar, certifique-se:
- ✅ App compila sem erros
- ✅ Funcionalidades testadas
- ✅ Código organizado
- ✅ `.gitignore` configurado

---

## 1️⃣ Preparar o Repositório Local

### 1.1 Verificar Status do Git

```bash
cd C:\mobile_anemia_detector
git status
```

**Se já existe Git:**
- Verifique se há commits pendentes
- Se necessário, faça commit das mudanças

**Se não existe Git:**
- Continue com os próximos passos

### 1.2 Inicializar Git (se necessário)

```bash
git init
```

Isso cria um repositório Git local vazio.

### 1.3 Verificar Arquivos que Serão Commitados

```bash
git status
```

Isso mostra:
- ✅ **Arquivos não rastreados** (serão adicionados)
- ✅ **Arquivos modificados** (serão atualizados)
- ❌ **Arquivos ignorados** (não serão commitados)

### 1.4 Verificar .gitignore

O arquivo `.gitignore` já está configurado e ignora:
- `/build/` - Arquivos de build
- `.dart_tool/` - Ferramentas Dart
- `*.iml` - Arquivos do IntelliJ
- `.vscode/` - Configurações do VS Code
- Arquivos temporários

**⚠️ IMPORTANTE - Modelo TFLite:**

O arquivo `assets/model.tflite` **NÃO** está no `.gitignore` por padrão.

**Opções:**

**A) Incluir o modelo no Git** (repositório completo):
- Útil se o modelo for pequeno e você quiser clonar tudo
- O modelo será commitado normalmente

**B) Excluir o modelo do Git** (recomendado para repositórios públicos):
```bash
# Adicionar ao .gitignore
echo "assets/model.tflite" >> .gitignore

# Se já foi commitado, remover do Git (mas manter localmente)
git rm --cached assets/model.tflite
```

**C) Usar Git LFS** (para arquivos grandes):
```bash
# Instalar Git LFS
git lfs install

# Rastrear arquivos .tflite
git lfs track "*.tflite"

# Adicionar .gitattributes
git add .gitattributes
```

**Recomendação**: Para TCC, geralmente é melhor **incluir o modelo** para facilitar a reprodução dos resultados.

---

## 2️⃣ Criar Repositório no GitHub

### 2.1 Acessar GitHub

1. Acesse: https://github.com
2. Faça login na sua conta
3. Se não tem conta, clique em **"Sign up"** e crie uma

### 2.2 Criar Novo Repositório

1. Clique no botão **"+"** no canto superior direito
2. Selecione **"New repository"**

### 2.3 Preencher Informações do Repositório

**Repository name:**
```
mobile-anemia-detector
```
ou
```
anemia-detector-app
```
ou qualquer nome descritivo (sem espaços, minúsculas, hífens permitidos)

**Description:**
```
Aplicativo móvel Flutter para diagnóstico de anemia em ovinos usando Machine Learning on-device com TensorFlow Lite
```

**Visibility:**
- ✅ **Public** - Visível para todos (recomendado para TCC/portfólio)
- ✅ **Private** - Apenas você e colaboradores (recomendado durante desenvolvimento)

**⚠️ NÃO marque estas opções:**
- ❌ "Add a README file" (já temos um)
- ❌ "Add .gitignore" (já temos um)
- ❌ "Choose a license" (adicione depois se quiser)

### 2.4 Criar Repositório

1. Clique em **"Create repository"**
2. Você será redirecionado para a página do repositório

### 2.5 Copiar URL do Repositório

Na página do repositório, você verá uma URL como:
```
https://github.com/seu-usuario/mobile-anemia-detector.git
```

**Copie esta URL** - você precisará dela no próximo passo.

**Alternativa SSH:**
Se você configurou SSH keys:
```
git@github.com:seu-usuario/mobile-anemia-detector.git
```

---

## 3️⃣ Conectar Repositório Local ao GitHub

### 3.1 Adicionar Remote

```bash
git remote add origin https://github.com/SEU-USUARIO/mobile-anemia-detector.git
```

**Substitua:**
- `SEU-USUARIO` pelo seu nome de usuário do GitHub
- `mobile-anemia-detector` pelo nome do seu repositório

**Exemplo:**
```bash
git remote add origin https://github.com/joaosilva/mobile-anemia-detector.git
```

### 3.2 Verificar Remote

```bash
git remote -v
```

**Saída esperada:**
```
origin  https://github.com/SEU-USUARIO/mobile-anemia-detector.git (fetch)
origin  https://github.com/SEU-USUARIO/mobile-anemia-detector.git (push)
```

### 3.3 Se o Remote Já Existe

Se você receber erro "remote origin already exists":

```bash
# Verificar remote atual
git remote -v

# Remover remote existente
git remote remove origin

# Adicionar novamente
git remote add origin https://github.com/SEU-USUARIO/mobile-anemia-detector.git
```

---

## 4️⃣ Fazer Primeiro Commit

### 4.1 Adicionar Arquivos ao Staging

**Opção A: Adicionar todos os arquivos** (recomendado para primeiro commit):
```bash
git add .
```

**Opção B: Adicionar arquivos específicos:**
```bash
git add lib/
git add android/
git add ios/
git add pubspec.yaml
git add README.md
git add .gitignore
git add assets/
```

### 4.2 Verificar Arquivos Adicionados

```bash
git status
```

**Saída esperada:**
```
On branch main

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        new file:   lib/main.dart
        new file:   lib/core/...
        new file:   android/...
        new file:   pubspec.yaml
        ...
```

### 4.3 Criar Commit

**Commit com mensagem simples:**
```bash
git commit -m "Initial commit: Anemia Detector app"
```

**Commit com mensagem detalhada:**
```bash
git commit -m "Initial commit: Anemia Detector app

- App Flutter para diagnóstico de anemia em ovinos
- Machine Learning on-device com TFLite
- Segmentação de imagem da conjuntiva ocular
- Interface moderna com animações
- Suporte Android
- Processamento otimizado com isolates"
```

### 4.4 Verificar Commits

```bash
git log
```

**Saída esperada:**
```
commit abc123def456... (HEAD -> main)
Author: Seu Nome <seu.email@exemplo.com>
Date:   Mon Jan 1 12:00:00 2024 -0300

    Initial commit: Anemia Detector app
```

---

## 5️⃣ Enviar para o GitHub

### 5.1 Renomear Branch para Main (se necessário)

```bash
git branch -M main
```

**Nota**: GitHub usa `main` como branch padrão (antigamente era `master`).

### 5.2 Push Inicial

```bash
git push -u origin main
```

**O `-u` configura o tracking**, então próximos pushes serão apenas:
```bash
git push
```

### 5.3 Autenticação

**Se pedir usuário e senha:**

**⚠️ IMPORTANTE**: GitHub não aceita mais senha normal. Use **Personal Access Token**.

#### Criar Personal Access Token:

1. Acesse: https://github.com/settings/tokens
2. Clique em **"Generate new token"** → **"Generate new token (classic)"**
3. Preencha:
   - **Note**: `Flutter Project` (qualquer nome)
   - **Expiration**: 90 dias (ou conforme necessário)
   - **Scopes**: Marque `repo` (acesso completo a repositórios)
4. Clique em **"Generate token"**
5. **COPIE O TOKEN** (ele só aparece uma vez!)
   - Exemplo: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

#### Usar o Token:

**No prompt de autenticação:**
- **Username**: Seu nome de usuário do GitHub
- **Password**: Cole o token (não sua senha!)

**Exemplo de saída:**
```
Username for 'https://github.com': seu-usuario
Password for 'https://seu-usuario@github.com': ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 5.4 Verificar Push Bem-Sucedido

**Saída esperada:**
```
Enumerating objects: 150, done.
Counting objects: 100% (150/150), done.
Delta compression using up to 8 threads
Compressing objects: 100% (120/120), done.
Writing objects: 100% (150/150), 2.5 MiB | 5.00 MiB/s, done.
Total 150 (delta 30), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (30/30), done.
To https://github.com/SEU-USUARIO/mobile-anemia-detector.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

### 5.5 Verificar no GitHub

1. Acesse seu repositório: `https://github.com/SEU-USUARIO/mobile-anemia-detector`
2. Verifique se todos os arquivos aparecem
3. Confira se o README.md está visível

---

## 6️⃣ Atualizar README.md

Antes de fazer o commit, atualize o `README.md` com informações completas do projeto.

### 6.1 Template de README Completo

```markdown
# 🐑 Anemia Detector

Aplicativo móvel Flutter para diagnóstico de anemia em ovinos usando Machine Learning on-device.

## 📱 Sobre

O **Anemia Detector** é um aplicativo desenvolvido para auxiliar veterinários e produtores rurais no diagnóstico de anemia em ovinos através da análise da conjuntiva ocular. O app utiliza segmentação de imagem com TensorFlow Lite para processamento local, garantindo privacidade e rapidez na análise.

## 🚀 Características

- ✅ **Machine Learning on-device** - Processamento local sem servidor
- ✅ **Segmentação de imagem** - Detecção da região da mucosa
- ✅ **Interface moderna** - Design com animações e gradientes
- ✅ **Processamento otimizado** - Uso de isolates para melhor performance
- ✅ **Suporte completo** - Câmera e galeria de fotos
- ✅ **100% Offline** - Funciona sem internet

## 🛠️ Tecnologias

- **Flutter** - Framework multiplataforma
- **TensorFlow Lite** - Machine Learning on-device
- **Dart** - Linguagem de programação
- **Image Processing** - Processamento e manipulação de imagens

## 📋 Pré-requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Dispositivo Android ou emulador
- Modelo TFLite (`assets/model.tflite`)

## 🔧 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/SEU-USUARIO/mobile-anemia-detector.git
cd mobile-anemia-detector
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Adicione o modelo TFLite

Coloque o arquivo `model.tflite` em:
```
assets/model.tflite
```

**Nota**: Se você tem um modelo `.keras`, use o script de conversão:
```bash
python converter_com_custom_loss.py
```

Veja [CONVERSAO_MODELO.md](CONVERSAO_MODELO.md) para mais detalhes.

### 4. Execute o app

```bash
flutter run
```

## 📸 Screenshots

Adicione screenshots do app aqui:
```
[Adicione screenshots do app]
```

## 🏗️ Estrutura do Projeto

```
mobile_anemia_detector/
├── lib/
│   ├── main.dart                    # Ponto de entrada
│   ├── core/                        # Componentes core
│   │   ├── ml/                      # Serviços de ML
│   │   ├── widgets/                 # Widgets reutilizáveis
│   │   └── theme/                   # Tema do app
│   └── features/                    # Features do app
├── android/                         # Configuração Android
├── assets/
│   └── model.tflite                 # Modelo TFLite
└── pubspec.yaml                     # Dependências
```

## 📚 Documentação

- [Guia de Configuração](CONFIGURACAO.md)
- [Conversão de Modelo](CONVERSAO_MODELO.md)
- [Revisão do Projeto](REVISAO_PROJETO.md)

## 🔬 Como Funciona

1. **Captura de Imagem**: O usuário tira uma foto da conjuntiva ocular do ovino
2. **Recorte**: Recorta a área de interesse (opcional)
3. **Pré-processamento**: A imagem é redimensionada para 256x256 e normalizada
4. **Inferência**: O modelo TFLite processa a imagem e gera máscara de segmentação
5. **Pós-processamento**: A máscara é processada e visualizada com overlay
6. **Resultados**: Exibe a porcentagem de cobertura da região segmentada

## 📊 Especificações do Modelo

- **Input**: `[1, 256, 256, 3]` - Imagem RGB normalizada [0-1]
- **Output**: `[1, 256, 256, 1]` - Máscara de segmentação
- **Tipo**: Segmentação de imagem (U-Net)
- **Framework**: TensorFlow Lite

## 🧪 Testes

```bash
flutter test
```

## 📝 Licença

Este projeto é parte de um trabalho de conclusão de curso (TCC).

## 👤 Autor

**Seu Nome**
- Email: seu.email@exemplo.com
- GitHub: [@seu-usuario](https://github.com/seu-usuario)

## 🙏 Agradecimentos

- [TensorFlow](https://www.tensorflow.org/) - Framework de ML
- [Flutter](https://flutter.dev/) - Framework multiplataforma
- Comunidade Flutter e TensorFlow

## 📄 Referências

- Sistema FAMACHA para diagnóstico de anemia
- U-Net para segmentação de imagens
- TensorFlow Lite para ML on-device

---

⭐ Se este projeto foi útil, considere dar uma estrela!
```

### 6.2 Adicionar Screenshots

Crie uma pasta `docs/screenshots/` e adicione imagens do app:
```markdown
![Tela Principal](docs/screenshots/main_screen.png)
![Resultados](docs/screenshots/results.png)
```

### 6.3 Fazer Commit do README

```bash
git add README.md
git commit -m "docs: atualizar README com informações completas do projeto"
git push
```

---

## 7️⃣ Commits Futuros

### 7.1 Workflow para Atualizações

**1. Verificar mudanças:**
```bash
git status
```

**2. Adicionar arquivos modificados:**
```bash
git add .
# ou arquivos específicos:
git add lib/main.dart
```

**3. Criar commit com mensagem descritiva:**
```bash
git commit -m "feat: adicionar funcionalidade X"
```

**4. Enviar para GitHub:**
```bash
git push
```

### 7.2 Convenções de Commit

Use prefixos para organizar commits:

- **feat**: Nova funcionalidade
  ```bash
  git commit -m "feat: adicionar salvamento de resultados"
  ```

- **fix**: Correção de bug
  ```bash
  git commit -m "fix: corrigir erro de overflow no botão"
  ```

- **docs**: Documentação
  ```bash
  git commit -m "docs: atualizar guia de instalação"
  ```

- **refactor**: Refatoração de código
  ```bash
  git commit -m "refactor: reorganizar estrutura de pastas"
  ```

- **style**: Formatação, espaços, etc.
  ```bash
  git commit -m "style: corrigir indentação"
  ```

- **test**: Testes
  ```bash
  git commit -m "test: adicionar testes unitários"
  ```

- **chore**: Tarefas de manutenção
  ```bash
  git commit -m "chore: atualizar dependências"
  ```

### 7.3 Dicas para Commits

✅ **Faça:**
- Commits frequentes (não acumule muitas mudanças)
- Mensagens descritivas e claras
- Commits focados (uma funcionalidade por commit)
- Commits pequenos e atômicos

❌ **Evite:**
- Commits muito grandes
- Mensagens vagas como "fix" ou "update"
- Misturar funcionalidades diferentes no mesmo commit
- Commits que quebram o build

### 7.4 Ver Histórico de Commits

```bash
# Ver commits recentes
git log

# Ver commits de forma compacta
git log --oneline

# Ver mudanças de um commit específico
git show abc123
```

---

## 8️⃣ Segurança e Privacidade

### 8.1 Arquivos Sensíveis

**⚠️ ATENÇÃO**: Antes de fazer push, verifique se não está commitando:

- ❌ **Chaves de API** ou tokens
- ❌ **Senhas** ou credenciais
- ❌ **Arquivos de configuração local** (`local.properties`)
- ❌ **Certificados de assinatura** (`.keystore`, `.jks`)
- ❌ **Informações pessoais** de usuários

### 8.2 Adicionar ao .gitignore

Se necessário, adicione ao `.gitignore`:

```gitignore
# Arquivos sensíveis
*.keystore
*.jks
local.properties
secrets.properties
.env
*.key
android/key.properties

# Arquivos de configuração local
android/local.properties
ios/Pods/
```

### 8.3 Remover Arquivos já Commitados

Se você commitou algo por engano:

**1. Remover do Git (mas manter localmente):**
```bash
git rm --cached arquivo-sensivel.txt
```

**2. Adicionar ao .gitignore:**
```bash
echo "arquivo-sensivel.txt" >> .gitignore
```

**3. Fazer commit da remoção:**
```bash
git add .gitignore
git commit -m "remove: arquivo sensível do repositório"
git push
```

**⚠️ IMPORTANTE**: Se você já fez push, o arquivo ainda estará no histórico do Git. Para removê-lo completamente, use `git filter-branch` ou `git filter-repo` (avançado).

### 8.4 Verificar Antes de Push

**Comando útil:**
```bash
# Ver o que será commitado
git diff --cached

# Ver arquivos que serão enviados
git ls-files
```

---

## 9️⃣ Branches (Opcional)

### 9.1 Por que Usar Branches?

- ✅ Trabalhar em features sem afetar o código principal
- ✅ Colaborar com outros desenvolvedores
- ✅ Testar mudanças antes de merge
- ✅ Manter histórico organizado

### 9.2 Criar e Trabalhar em Branch

**Criar nova branch:**
```bash
git checkout -b feature/nova-funcionalidade
```

**Ou usando branch main atualizada:**
```bash
git checkout -b feature/nova-funcionalidade main
```

**Trabalhar na branch:**
```bash
# Fazer mudanças no código
# ...

# Adicionar e commitar
git add .
git commit -m "feat: implementar nova funcionalidade"
```

**Enviar branch para GitHub:**
```bash
git push -u origin feature/nova-funcionalidade
```

### 9.3 Voltar para Main e Fazer Merge

**Voltar para main:**
```bash
git checkout main
```

**Atualizar main:**
```bash
git pull origin main
```

**Fazer merge da branch:**
```bash
git merge feature/nova-funcionalidade
```

**Resolver conflitos** (se houver):
- Git mostrará arquivos com conflitos
- Edite os arquivos manualmente
- Depois: `git add .` e `git commit`

**Enviar merge:**
```bash
git push
```

### 9.4 Deletar Branch

**Deletar branch local:**
```bash
git branch -d feature/nova-funcionalidade
```

**Deletar branch remota:**
```bash
git push origin --delete feature/nova-funcionalidade
```

### 9.5 Pull Requests (GitHub)

Para colaboração, use Pull Requests:

1. Crie uma branch e faça push
2. No GitHub, clique em **"Compare & pull request"**
3. Preencha informações do PR
4. Aguarde revisão
5. Merge após aprovação

---

## 🔟 Troubleshooting

### Erro: "remote origin already exists"

**Solução:**
```bash
git remote remove origin
git remote add origin https://github.com/SEU-USUARIO/mobile-anemia-detector.git
```

### Erro: "failed to push some refs"

**Causa**: Branch remota tem commits que você não tem localmente.

**Solução:**
```bash
# Fazer pull primeiro
git pull origin main --allow-unrelated-histories

# Resolver conflitos (se houver)
# Depois fazer push novamente
git push -u origin main
```

### Erro: "authentication failed"

**Causa**: Token expirado ou inválido.

**Solução:**
1. Gere novo token: https://github.com/settings/tokens
2. Use o token como senha
3. Ou configure SSH keys

### Erro: "Permission denied"

**Causa**: Não tem permissão no repositório.

**Solução:**
- Verifique se você é dono/colaborador do repositório
- Verifique se o token tem escopo `repo`

### Arquivo muito grande para Git

**Causa**: Modelo TFLite pode ser muito grande.

**Solução:**
```bash
# Usar Git LFS
git lfs install
git lfs track "*.tflite"
git add .gitattributes
git add assets/model.tflite
git commit -m "add: modelo usando Git LFS"
```

### Desfazer Último Commit (antes do push)

```bash
# Mantém mudanças
git reset --soft HEAD~1

# Remove mudanças
git reset --hard HEAD~1
```

### Desfazer Último Commit (depois do push)

**⚠️ CUIDADO**: Isso reescreve o histórico!

```bash
git reset --hard HEAD~1
git push --force
```

**Só use se:**
- Trabalhando sozinho
- Ou coordenado com outros desenvolvedores

---

## ✅ Checklist Final

Antes de publicar, verifique:

- [ ] Git instalado e configurado
- [ ] `.gitignore` configurado corretamente
- [ ] README.md atualizado com informações completas
- [ ] Nenhum arquivo sensível será commitado
- [ ] Modelo TFLite incluído ou excluído conforme necessário
- [ ] Código testado e funcionando
- [ ] Commits com mensagens descritivas
- [ ] Repositório criado no GitHub
- [ ] Remote configurado corretamente
- [ ] Personal Access Token criado (se necessário)
- [ ] Push realizado com sucesso
- [ ] Arquivos visíveis no GitHub

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Flutter Git Workflow](https://docs.flutter.dev/development/tools/version-control)

### Tutoriais
- [Git Tutorial](https://www.atlassian.com/git/tutorials)
- [GitHub Learning Lab](https://lab.github.com/)

### Ferramentas
- [GitHub Desktop](https://desktop.github.com/) - Interface gráfica
- [SourceTree](https://www.sourcetreeapp.com/) - Cliente Git visual
- [GitKraken](https://www.gitkraken.com/) - Cliente Git visual

---

## 🎉 Conclusão

Agora seu projeto está no GitHub! Você pode:

- ✅ Compartilhar o código
- ✅ Colaborar com outros desenvolvedores
- ✅ Manter histórico de versões
- ✅ Fazer backup do código
- ✅ Mostrar seu trabalho em portfólio

**Próximos passos:**
- Adicione uma licença (MIT, Apache, etc.)
- Configure GitHub Actions para CI/CD (opcional)
- Adicione badges ao README (build status, etc.)
- Crie releases/tags para versões importantes

---

**Boa sorte com seu projeto!** 🚀

Se tiver dúvidas, consulte a documentação do Git ou abra uma issue no GitHub.

