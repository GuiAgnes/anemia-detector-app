# 📱 Guia Completo: Publicar App nas Lojas

## 📋 Índice

1. [Google Play Store (Android)](#-google-play-store-android)
   - [Preparação](#preparação)
   - [Assinatura](#assinatura)
   - [Build de Release](#build-de-release)
   - [Publicação](#publicação)
2. [Apple App Store (iOS)](#-apple-app-store-ios)
   - [Preparação](#preparação-1)
   - [Configuração](#configuração)
   - [Build e Upload](#build-e-upload)
   - [Publicação](#publicação-1)
3. [Checklist Final](#-checklist-final)
4. [Troubleshooting](#-troubleshooting)

---

# 🟢 Google Play Store (Android)

## 📋 Pré-requisitos

### 1. Conta Google Play Console

- **Criar conta**: https://play.google.com/console
- **Taxa**: $25 USD (pagamento único, válido para sempre)
- **Aprovação**: 1-2 dias úteis
- **Cartão de crédito**: Necessário para pagar a taxa

### 2. Certificado de Assinatura (Keystore)

Necessário para assinar o APK/AAB e garantir autenticidade.

### 3. Assets Necessários

- ✅ Ícone do app (já configurado)
- ✅ Splash screen (já configurado)
- 📸 Screenshots (mínimo 2, recomendado 4-8)
- 📝 Descrição do app
- 🎨 Feature graphic (1024x500 px)
- 📄 Política de privacidade (URL)

---

## 🔐 Passo 1: Criar Certificado de Assinatura

### 1.1 Gerar Keystore

**No terminal, na pasta do projeto:**

```bash
cd android
keytool -genkey -v -keystore anemia-detector-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias anemia-detector
```

**Informações solicitadas:**

1. **Password**: Escolha uma senha forte
   - **⚠️ GUARDE BEM!** Você precisará desta senha sempre
   - Recomendado: Use um gerenciador de senhas
   - Mínimo: 6 caracteres

2. **Nome e Organização**:
   ```
   Nome: Seu Nome Completo
   Unidade organizacional: Desenvolvimento (ou seu departamento)
   Organização: Sua Empresa/Universidade (ou seu nome)
   Cidade: Sua Cidade
   Estado/Província: Seu Estado
   Código do país: BR
   ```

3. **Confirmação**: Digite `yes` para confirmar

**Exemplo de saída:**
```
Gerando chave auto-assinada de 2.048 bits e certificado SHA256 com RSA
        válido por 10.000 dias
        para: CN=João Silva, OU=Desenvolvimento, O=Universidade XYZ, L=São Paulo, ST=SP, C=BR
[Armazenando anemia-detector-key.jks]
```

**⚠️ IMPORTANTE**: 
- O arquivo `anemia-detector-key.jks` será criado
- **FAÇA BACKUP** deste arquivo e da senha
- Se perder, você não poderá atualizar o app na Play Store

### 1.2 Criar Arquivo key.properties

**Crie o arquivo**: `android/key.properties`

```properties
storePassword=SUA_SENHA_KEYSTORE
keyPassword=SUA_SENHA_KEY
keyAlias=anemia-detector
storeFile=anemia-detector-key.jks
```

**Substitua:**
- `SUA_SENHA_KEYSTORE` pela senha que você criou
- `SUA_SENHA_KEY` pela mesma senha (ou senha diferente se especificou)

**⚠️ SEGURANÇA**: Este arquivo contém senhas!

### 1.3 Adicionar ao .gitignore

**IMPORTANTE**: Nunca commite o keystore ou key.properties!

```bash
# Adicionar ao .gitignore
echo "android/key.properties" >> .gitignore
echo "android/*.jks" >> .gitignore
echo "android/*.keystore" >> .gitignore
```

### 1.4 Backup do Keystore

**Faça backup em locais seguros:**
- Pendrive criptografado
- Google Drive (com senha)
- Serviço de backup na nuvem

**Comando para backup:**
```bash
# Copiar para local seguro
copy android\anemia-detector-key.jks C:\Backup\anemia-detector-key.jks
```

---

## 🏗️ Passo 2: Configurar Assinatura no Build

### 2.1 Atualizar build.gradle.kts

**Edite**: `android/app/build.gradle.kts`

**Adicione no início do arquivo (antes do `android {`):**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Carregar propriedades do keystore
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

**Atualize a seção `android {`:**
```kotlin
android {
    namespace = "com.example.mobile_anemia_detector"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Mude para seu Application ID único
        applicationId = "com.seudominio.anemiadetector"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1  // Incremente a cada release
        versionName = "1.0.0"  // Versão visível aos usuários
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Otimizações para reduzir tamanho
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
```

### 2.2 Criar Proguard Rules (Opcional)

**Crie**: `android/app/proguard-rules.pro`

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
```

### 2.3 Atualizar Application ID

**Mude o Application ID para algo único:**

```kotlin
applicationId = "com.seudominio.anemiadetector"
```

**Exemplos:**
- `com.seudominio.anemiadetector`
- `com.seunome.anemiadetector`
- `br.com.universidade.anemiadetector`

**⚠️ IMPORTANTE**: 
- Deve ser único (não pode ser usado por outro app)
- Uma vez publicado, não pode ser alterado
- Use formato reverso de domínio

---

## 🏗️ Passo 3: Preparar App para Release

### 3.1 Atualizar Version

**Edite**: `pubspec.yaml`
```yaml
version: 1.0.0+1
```
**Formato**: `versionName+versionCode`
- `1.0.0` = Versão visível (ex: 1.0.0, 1.1.0, 2.0.0)
- `+1` = Version code (1, 2, 3, 4...)

**Ou edite diretamente em `build.gradle.kts`:**
```kotlin
versionCode = 1
versionName = "1.0.0"
```

### 3.2 Atualizar AndroidManifest.xml

**Verifique**: `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="Anemia Detector"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher">
```

### 3.3 Testar Build de Release

**Limpar build anterior:**
```bash
flutter clean
```

**Build App Bundle (recomendado):**
```bash
flutter build appbundle --release
```

**Ou APK (para testes):**
```bash
flutter build apk --release
```

**Arquivos gerados:**
- **AAB**: `build/app/outputs/bundle/release/app-release.aab` (Play Store)
- **APK**: `build/app/outputs/flutter-apk/app-release.apk` (testes)

**Testar APK:**
```bash
# Instalar no dispositivo conectado
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📸 Passo 4: Preparar Assets para Play Store

### 4.1 Screenshots Obrigatórios

**Tamanhos necessários:**
- **Phone**: Mínimo 2 screenshots
  - Largura mínima: 320px
  - Largura máxima: 3840px
  - Altura máxima: 3840px
  - Proporção: Entre 16:9 e 9:16

**Tamanhos recomendados:**
- Phone: 1080x1920 px (vertical) ou 1920x1080 px (horizontal)
- Tablet: 1600x2560 px (opcional)

**Como capturar:**

**Opção A: Emulador Android**
```bash
# Iniciar emulador
flutter run

# Tirar screenshot
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshots/
```

**Opção B: Dispositivo Real**
- Use botões de screenshot do dispositivo
- Ou use ferramentas de captura

**Opção C: Ferramentas Online**
- App Screenshot Generator
- Mockup Generator

**Telas recomendadas para screenshots:**
1. Tela inicial (com modelo carregado)
2. Diálogo de seleção de imagem
3. Tela de processamento
4. Tela de resultados (com segmentação)
5. Tela de estatísticas

### 4.2 Feature Graphic

**Especificações:**
- **Tamanho**: 1024x500 px
- **Formato**: PNG ou JPG
- **Conteúdo**: Banner promocional do app

**Dicas de design:**
- Use as cores do app
- Inclua nome do app
- Mostre função principal
- Mantenha texto legível

**Criar usando:**
- Canva (https://canva.com)
- Figma (https://figma.com)
- Photoshop/GIMP

### 4.3 Ícone de Alta Resolução

**Especificações:**
- **Tamanho**: 512x512 px
- **Formato**: PNG (32-bit com transparência)
- **Conteúdo**: Ícone do app

**Você já tem**: `playstore.png` na pasta Icone

### 4.4 Organizar Assets

**Criar estrutura:**
```
play-store-assets/
├── screenshots/
│   ├── phone/
│   │   ├── screenshot1.png
│   │   ├── screenshot2.png
│   │   └── ...
│   └── tablet/ (opcional)
├── feature-graphic.png
└── icon-512.png
```

---

## 🚀 Passo 5: Criar Conta no Google Play Console

### 5.1 Criar Conta

1. Acesse: https://play.google.com/console
2. Clique em **"Criar conta"** ou **"Sign up"**
3. Faça login com sua conta Google
4. Aceite os termos de serviço

### 5.2 Pagar Taxa de Registro

1. Vá em **"Configurações"** → **"Conta"**
2. Clique em **"Pagar taxa de registro"**
3. Taxa: **$25 USD** (pagamento único)
4. Métodos aceitos: Cartão de crédito/débito
5. Aguarde aprovação (1-2 dias úteis)

**⚠️ IMPORTANTE**: 
- A taxa é única para sempre
- Válida para todos os apps que você publicar
- Não é reembolsável

---

## 🚀 Passo 6: Criar Novo App

### 6.1 Criar App

1. No Play Console, clique em **"Criar app"**
2. Preencha informações:

**Nome do app:**
```
Anemia Detector
```

**Idioma padrão:**
```
Português (Brasil)
```

**Tipo de app:**
```
App
```

**Gratuito ou pago:**
```
Gratuito
```
(Se quiser cobrar depois, pode mudar)

**Declarações:**
- ✅ Declare que você tem todos os direitos
- ✅ Política de privacidade (URL obrigatória)

### 6.2 Preencher Informações do App

#### Categorização

**Categoria:**
```
Saúde e fitness
```

**Tags** (opcional):
```
veterinária, diagnóstico, ovinos, inteligência artificial, machine learning
```

#### Detalhes do app

**Título** (máximo 50 caracteres):
```
Anemia Detector
```

**Descrição curta** (máximo 80 caracteres):
```
Diagnóstico de anemia em ovinos usando IA e análise de imagens
```

**Descrição completa** (máximo 4000 caracteres):
```
🐑 SOBRE O APP

O Anemia Detector é um aplicativo móvel desenvolvido para auxiliar 
veterinários e produtores rurais no diagnóstico de anemia em ovinos 
através da análise da conjuntiva ocular.

🚀 CARACTERÍSTICAS PRINCIPAIS

✓ Análise de imagem usando Machine Learning on-device
✓ Processamento rápido e preciso
✓ Interface intuitiva e moderna
✓ Funciona 100% offline (sem necessidade de internet)
✓ Baseado no sistema FAMACHA
✓ Processamento local garante privacidade dos dados

📸 COMO USAR

1. Abra o aplicativo
2. Tire uma foto da conjuntiva ocular do ovino
3. Recorte a área de interesse (opcional)
4. O app analisa a imagem automaticamente
5. Visualize os resultados da segmentação
6. Acompanhe a porcentagem de cobertura da região

🔬 TECNOLOGIA

O Anemia Detector utiliza TensorFlow Lite para processamento de 
imagem local, garantindo:
• Privacidade - dados nunca saem do dispositivo
• Rapidez - processamento instantâneo
• Confiabilidade - funciona sem internet
• Eficiência - otimizado para dispositivos móveis

⚠️ AVISO IMPORTANTE

Este aplicativo é uma ferramenta de auxílio e não substitui 
o diagnóstico profissional de um veterinário. Sempre consulte 
um profissional qualificado para decisões importantes sobre 
a saúde dos animais.

📱 REQUISITOS

• Android 5.0 (API 21) ou superior
• Câmera ou acesso à galeria de fotos
• Permissões de câmera e armazenamento

📧 CONTATO

Para dúvidas, sugestões ou problemas:
seu-email@exemplo.com

---

Versão 1.0.0
Desenvolvido como trabalho de conclusão de curso (TCC)
```

#### Gráficos

**Upload de screenshots:**
1. Vá em **"Gráficos"**
2. Faça upload das screenshots (mínimo 2)
3. Arraste para ordenar (a primeira será a principal)

**Feature graphic:**
1. Upload do arquivo `feature-graphic.png` (1024x500)

**Ícone de alta resolução:**
1. Upload do `icon-512.png` (512x512)

---

## 🚀 Passo 7: Enviar AAB para Revisão

### 7.1 Criar Versão de Produção

1. No Play Console, vá em **"Produção"** (menu lateral)
2. Clique em **"Criar nova versão"**

### 7.2 Fazer Upload do AAB

1. Clique em **"Fazer upload de um novo arquivo de versão"**
2. Selecione: `build/app/outputs/bundle/release/app-release.aab`
3. Aguarde o upload (pode levar alguns minutos)
4. Google validará o arquivo automaticamente

**Se houver erros:**
- Verifique mensagens de erro
- Corrija problemas indicados
- Faça novo build e upload

### 7.3 Preencher Notas de Versão

**Para usuários** (máximo 500 caracteres):
```
Versão inicial do Anemia Detector

Novidades:
• Análise de segmentação da conjuntiva ocular
• Interface moderna e intuitiva
• Processamento on-device com TensorFlow Lite
• Funciona 100% offline
• Suporte para câmera e galeria
```

**Internas** (apenas para você):
```
Versão 1.0.0 - Release inicial
- Primeira versão publicada
- Funcionalidades básicas implementadas
```

### 7.4 Revisar Lançamento

1. Clique em **"Revisar lançamento"**
2. Verifique todas as informações:
   - ✅ Versão correta
   - ✅ AAB válido
   - ✅ Notas de versão
   - ✅ Informações do app completas

### 7.5 Iniciar Lançamento

1. Clique em **"Iniciar lançamento para produção"**
2. Confirme o lançamento
3. App será enviado para revisão

**Tempo de revisão**: 1-3 dias úteis (geralmente)

---

## 📋 Passo 8: Preencher Questionários e Políticas

### 8.1 Política de Privacidade

**Obrigatória!** Crie uma página com política de privacidade.

**Onde hospedar:**
- GitHub Pages (gratuito)
- Netlify (gratuito)
- Seu próprio site
- Google Sites

**Template de política:**

Crie um arquivo HTML e hospede:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Política de Privacidade - Anemia Detector</title>
</head>
<body>
    <h1>Política de Privacidade - Anemia Detector</h1>
    
    <p><strong>Última atualização:</strong> [Data]</p>
    
    <h2>1. Informações Gerais</h2>
    <p>O Anemia Detector respeita sua privacidade e está comprometido 
    em proteger seus dados pessoais.</p>
    
    <h2>2. Dados Coletados</h2>
    <p><strong>Nenhum dado pessoal é coletado.</strong></p>
    <ul>
        <li>O aplicativo funciona 100% offline</li>
        <li>Imagens processadas localmente no dispositivo</li>
        <li>Nenhuma informação é enviada para servidores</li>
        <li>Nenhum dado é armazenado externamente</li>
    </ul>
    
    <h2>3. Processamento de Imagens</h2>
    <p>As imagens capturadas ou selecionadas são processadas 
    exclusivamente no seu dispositivo usando TensorFlow Lite. 
    Nenhuma imagem é transmitida ou armazenada em servidores.</p>
    
    <h2>4. Permissões do App</h2>
    <ul>
        <li><strong>Câmera:</strong> Para capturar fotos da conjuntiva ocular</li>
        <li><strong>Galeria:</strong> Para selecionar imagens existentes</li>
        <li><strong>Armazenamento:</strong> Para salvar imagens recortadas temporariamente</li>
    </ul>
    
    <h2>5. Compartilhamento de Dados</h2>
    <p>Nenhum dado é compartilhado com terceiros. O aplicativo 
    não possui integração com serviços externos.</p>
    
    <h2>6. Segurança</h2>
    <p>Todo o processamento ocorre localmente no dispositivo, 
    garantindo máxima segurança e privacidade.</p>
    
    <h2>7. Alterações na Política</h2>
    <p>Esta política pode ser atualizada. A data da última 
    atualização será sempre indicada no topo desta página.</p>
    
    <h2>8. Contato</h2>
    <p>Para dúvidas sobre esta política:
    <br>Email: seu-email@exemplo.com</p>
</body>
</html>
```

**URL da política**: Adicione no Play Console em **"Política, privacidade e segurança"**

### 8.2 Classificação de Conteúdo

1. Vá em **"Classificação de conteúdo"**
2. Responda o questionário:
   - **Categoria**: Saúde e fitness
   - **Conteúdo**: Nenhum conteúdo restrito
   - **Acesso a dados**: Não solicita dados sensíveis

### 8.3 Declarações

**Programa de parceiros do Google Play:**
- ✅ "Não participo" (se não participar)
- ✅ "Participar" (se quiser monetizar)

**USK (Alemanha):**
- Classificação: Sem restrições

**Países e regiões:**
- Selecione onde o app estará disponível
- Recomendado: Todos os países (máxima visibilidade)

---

## ⏳ Aguardar Revisão

### Status da Revisão

**Acompanhar no Play Console:**
- **"Em revisão"**: App está sendo analisado
- **"Publicado"**: App disponível na Play Store! 🎉
- **"Rejeitado"**: Verifique motivos e corrija

**Tempo médio**: 1-3 dias úteis

**Você receberá e-mails** sobre mudanças de status.

### Se o App for Rejeitado

1. Leia cuidadosamente os motivos
2. Corrija os problemas apontados
3. Faça novo build
4. Envie nova versão
5. Aguarde nova revisão

---

# 🍎 Apple App Store (iOS)

## 📋 Pré-requisitos

### 1. Conta Apple Developer

- **Criar conta**: https://developer.apple.com
- **Taxa**: $99 USD/ano
- **Aprovação**: 24-48 horas
- **Requisitos**: Mac com Xcode (necessário para builds)

### 2. Mac com Xcode

- **macOS**: 13.0 ou superior
- **Xcode**: Versão mais recente
- **Instalar**: Via App Store

### 3. Certificados e Provisioning Profiles

- Configurados automaticamente pelo Xcode
- Ou manualmente no Apple Developer Portal

---

## 🏗️ Passo 1: Preparação

### 1.1 Abrir Projeto iOS no Xcode

```bash
cd ios
open Runner.xcworkspace
```

**⚠️ IMPORTANTE**: Use `.xcworkspace`, não `.xcodeproj`!

### 1.2 Configurar Bundle Identifier

1. No Xcode, selecione o projeto **Runner** (ícone azul)
2. Vá em **"Signing & Capabilities"**
3. Altere **Bundle Identifier**: 
   ```
   com.seudominio.anemiadetector
   ```
   (Deve ser único, formato reverso de domínio)

4. Selecione seu **Team** (Apple Developer Account)
5. Xcode criará automaticamente certificados e provisioning profiles

### 1.3 Configurar Informações do App

1. Vá em **"General"**
2. Preencha:
   - **Display Name**: `Anemia Detector`
   - **Version**: `1.0.0`
   - **Build**: `1` (incremente a cada release)
   - **Minimum Deployments**: iOS 12.0 ou superior

### 1.4 Adicionar Ícones iOS

**Copiar ícones:**
```bash
# Copiar arquivos do Assets.xcassets
cp -r "C:\Users\guuia\Downloads\Icone\Assets.xcassets\AppIcon.appiconset"/* ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

**Ou manualmente no Xcode:**
1. Vá em `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. Substitua os arquivos de ícone pelos seus

### 1.5 Configurar Permissões

**Edite**: `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Este aplicativo precisa acessar a câmera para fotografar a conjuntiva ocular dos ovinos.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Este aplicativo precisa acessar a galeria de fotos para selecionar imagens da conjuntiva ocular.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Este aplicativo precisa salvar imagens processadas.</string>
```

---

## 🏗️ Passo 2: Build e Archive

### 2.1 Selecionar Dispositivo

1. No Xcode, selecione **"Any iOS Device"** como destino
   (não selecione simulador)

### 2.2 Limpar Build

**Menu**: Product → Clean Build Folder (Shift + Cmd + K)

### 2.3 Criar Archive

**Menu**: Product → Archive

**Aguarde:**
- Compilação do projeto
- Criação do archive
- Validação automática

**Se houver erros:**
- Verifique mensagens de erro
- Corrija problemas de código
- Verifique certificados

### 2.4 Organizer Abre Automaticamente

Após o archive, o Organizer abre mostrando seu build.

---

## 🚀 Passo 3: Validar e Distribuir

### 3.1 Validar Archive

1. No Organizer, selecione o archive
2. Clique em **"Distribute App"**
3. Escolha **"App Store Connect"**
4. Clique em **"Next"**

**Opções de distribuição:**
- **App Store Connect**: Para publicação na App Store
- **Ad Hoc**: Para testes em dispositivos específicos
- **Enterprise**: Para distribuição empresarial
- **Development**: Para desenvolvimento

### 3.2 Escolher Opções

**Upload:**
- ✅ "Upload your app's symbols"
- ✅ "Manage version and build number"

**Clique em "Next"**

### 3.3 Validar

1. Xcode validará automaticamente
2. Se houver problemas, corrija e faça novo archive
3. Se tudo estiver OK, clique em **"Upload"**

**Aguarde o upload** (pode levar alguns minutos)

### 3.4 Verificar no App Store Connect

1. Acesse: https://appstoreconnect.apple.com
2. Vá em **"Meus Apps"**
3. Aguarde o build aparecer (pode levar 10-30 minutos)

---

## 🚀 Passo 4: Criar App no App Store Connect

### 4.1 Criar Novo App

1. Acesse: https://appstoreconnect.apple.com
2. Clique em **"Meus Apps"** → **"+"** → **"Novo App"**

### 4.2 Preencher Informações

**Plataforma:**
```
iOS
```

**Nome:**
```
Anemia Detector
```

**Idioma primário:**
```
Português (Brasil)
```

**Bundle ID:**
```
com.seudominio.anemiadetector
```
(Mesmo que você configurou no Xcode)

**SKU:**
```
anemia-detector-001
```
(Identificador único, não visível aos usuários)

### 4.3 Preencher Informações do App

#### Informações do App

**Nome** (máximo 30 caracteres):
```
Anemia Detector
```

**Subtítulo** (máximo 30 caracteres):
```
Diagnóstico de anemia em ovinos
```

**Categoria primária:**
```
Saúde e fitness
```

**Categoria secundária** (opcional):
```
Produtividade
```

**Classificação:**
```
4+ (sem conteúdo restrito)
```

#### Descrição

**Descrição** (máximo 4000 caracteres):
```
O Anemia Detector é um aplicativo móvel desenvolvido para auxiliar 
veterinários e produtores rurais no diagnóstico de anemia em ovinos 
através da análise da conjuntiva ocular.

🚀 CARACTERÍSTICAS

✓ Análise de imagem usando Machine Learning on-device
✓ Processamento rápido e preciso
✓ Interface intuitiva e moderna
✓ Funciona 100% offline
✓ Baseado no sistema FAMACHA

📸 COMO USAR

1. Tire uma foto da conjuntiva ocular do ovino
2. Recorte a área de interesse
3. O app analisa automaticamente
4. Visualize os resultados

⚠️ AVISO

Este aplicativo é uma ferramenta de auxílio e não substitui 
o diagnóstico profissional de um veterinário.
```

**Palavras-chave** (máximo 100 caracteres):
```
veterinária,diagnóstico,ovinos,anemia,ia,machine learning
```

#### Preços e Disponibilidade

**Preço:**
```
Gratuito
```

**Disponibilidade:**
```
Todos os países e regiões
```
(ou selecione países específicos)

### 4.4 Upload Screenshots

**Tamanhos necessários:**

- **iPhone 6.5" Display** (iPhone 11 Pro Max, etc.):
  - 1284 x 2778 px
  - Mínimo 3 screenshots

- **iPhone 6.7" Display** (iPhone 14 Pro Max, etc.):
  - 1290 x 2796 px
  - Mínimo 3 screenshots

**Como capturar:**
- Use simulador iOS no Xcode
- Ou dispositivo real
- Ferramentas de screenshot

### 4.5 Selecionar Build

1. Vá em **"Versão"** → **"+"**
2. Selecione o build que você fez upload
3. Preencha **"O que há de novo nesta versão"**:
```
Versão inicial do Anemia Detector

Novidades:
• Análise de segmentação da conjuntiva ocular
• Interface moderna e intuitiva
• Processamento on-device com Core ML
• Funciona 100% offline
```

### 4.6 Informações de Marketing

**URL de marketing** (opcional):
```
https://github.com/seu-usuario/mobile-anemia-detector
```

**Política de privacidade** (obrigatória):
```
https://seu-site.com/politica-privacidade
```

### 4.7 Enviar para Revisão

1. Revise todas as informações
2. Clique em **"Adicionar para revisão"**
3. Clique em **"Enviar para revisão"**
4. Confirme o envio

---

## ⏳ Aguardar Revisão iOS

**Tempo médio**: 1-7 dias úteis

**Status:**
- **"Aguardando revisão"**
- **"Em revisão"**
- **"Aprovado"** 🎉
- **"Rejeitado"** (verificar motivos)

---

## ✅ Checklist Final

### Android (Play Store)
- [ ] Keystore criado e backup feito
- [ ] key.properties configurado
- [ ] build.gradle.kts atualizado com signing
- [ ] Application ID único definido
- [ ] Versão atualizada (versionCode e versionName)
- [ ] AAB gerado e testado localmente
- [ ] Screenshots preparados (mínimo 2)
- [ ] Feature graphic criado (1024x500)
- [ ] Ícone de alta resolução (512x512)
- [ ] Descrição completa escrita
- [ ] Política de privacidade criada e hospedada
- [ ] Conta Play Console criada e taxa paga
- [ ] App criado no Play Console
- [ ] Informações do app preenchidas
- [ ] AAB enviado para revisão
- [ ] Questionários respondidos
- [ ] Classificação de conteúdo preenchida

### iOS (App Store)
- [ ] Conta Apple Developer ativa ($99/ano)
- [ ] Mac com Xcode instalado
- [ ] Bundle ID único configurado
- [ ] Certificados e provisioning profiles criados
- [ ] Ícones iOS adicionados
- [ ] Permissões configuradas no Info.plist
- [ ] Archive criado no Xcode
- [ ] Build validado e enviado
- [ ] App criado no App Store Connect
- [ ] Screenshots preparados (mínimo 3 por tamanho)
- [ ] Descrição completa escrita
- [ ] Política de privacidade criada e hospedada
- [ ] Build selecionado na versão
- [ ] Informações de marketing preenchidas
- [ ] App enviado para revisão

---

## 🔄 Versionamento

### Android

**Formato**: `versionName+versionCode`

**Exemplo**:
```yaml
version: 1.0.0+1
version: 1.0.1+2
version: 1.1.0+3
version: 2.0.0+4
```

**Ou em build.gradle.kts:**
```kotlin
versionCode = 1  // Incrementa sempre (1, 2, 3...)
versionName = "1.0.0"  // Versão semântica
```

### iOS

**Formato**: `Version (Build)`

**Exemplo**:
```
1.0.0 (1)
1.0.1 (2)
1.1.0 (3)
2.0.0 (4)
```

**No Xcode:**
- **Version**: `1.0.0` (visível aos usuários)
- **Build**: `1` (incrementa sempre)

---

## 🆘 Troubleshooting

### Android: "Failed to find target with hash string"
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### Android: "Keystore file not found"
- Verifique se `key.properties` está correto
- Verifique se o caminho do keystore está correto
- Certifique-se de que o keystore existe

### Android: "AAB validation failed"
- Verifique mensagens de erro no Play Console
- Certifique-se de que o AAB foi gerado corretamente
- Verifique se todas as permissões estão corretas

### iOS: "No signing certificate found"
- Verifique se o certificado está configurado no Xcode
- Vá em Xcode → Preferences → Accounts
- Clique em "Download Manual Profiles"
- Ou configure manualmente no Apple Developer Portal

### iOS: "Archive failed"
- Verifique erros de compilação
- Certifique-se de que todos os pods estão instalados:
  ```bash
  cd ios
  pod install
  ```
- Limpe o build: Product → Clean Build Folder

### Ambos: Rejeição na revisão
- Leia cuidadosamente os motivos da rejeição
- Corrija os problemas apontados
- Faça novo build e envie nova versão
- Pode levar várias tentativas

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)

### Tutoriais
- [Play Store Publishing Guide](https://developer.android.com/distribute/googleplay/start)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Ferramentas
- [App Icon Generator](https://appicon.co/)
- [Screenshot Generator](https://www.appstorescreenshot.com/)
- [Play Store Listing Optimizer](https://playboard.co/)

---

## 🎉 Conclusão

Agora você tem guias completos para publicar seu app em ambas as lojas!

**Lembre-se:**
- ✅ Faça backup do keystore (Android)
- ✅ Mantenha certificados seguros (iOS)
- ✅ Teste bem antes de publicar
- ✅ Leia as políticas das lojas
- ✅ Responda revisões rapidamente

**Boa sorte com a publicação!** 🚀📱

Se tiver dúvidas, consulte a documentação oficial ou comunidades de desenvolvedores.

