AppRedmine-Certto
=============

Aplicativo para abertura de tarefas no Redmine utilizando templates pré-definidos.

Templates atuais
-------------
- Devolução de material
- Informe de negociação em campo

Configurando ambiente de desenvolvimento
=============

Requisitos
-------------

- Java SDK
- Flutter SDK
- Android SDK

1 - Instalando Java SDK
-------------
É possivel utilizar o Oracle JDK 17 oficial ou o OpenJDK 7, ambos são compativeis com a aplicação.

- Realizar download do Oracle JDK 17.0.8 ([aqui](https://download.oracle.com/java/17/archive/jdk-17.0.8_windows-x64_bin.zip "aqui")).
- Extrair para local de preferencia (costumo usar C:\SDKs).
- Adicionar o diretório 'bin' ao PATH do sistema (C:\SDKs\jdk-17.0.8\bin).

Para verificar se a instalação foi bem sucedida, abra o prompt de comando e digite o seguinte comando:

`java --version`

O retorno deverá ser o seguinte:

    java 17.0.8 2023-07-18 LTS
    Java(TM) SE Runtime Environment (build 17.0.8+9-LTS-211)
    Java HotSpot(TM) 64-Bit Server VM (build 17.0.8+9-LTS-211, mixed mode, sharing)

2 - Instalando Flutter SDK
-------------
Flutter é o framework principal da aplicação, todo o código é escrito em Dart que já vem incluido junto ao SDK do Flutter.

- Realizar download do Flutter SDK ([aqui](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.10.6-stable.zip "aqui")).
- Extrair para local de preferencia (costumo usar C:\SDKs).
- Adicionar o diretório 'bin' ao PATH do sistema (C:\SDKs\flutter\bin).

Para verificar se a instalação foi bem sucedida, abra o prompt de comando e digite o seguinte comando:

`flutter --version`

O retorno deverá ser o seguinte:

    Flutter 3.10.6 • channel stable • https://github.com/flutter/flutter.git
    Framework • revision f468f3366c (3 weeks ago) • 2023-07-12 15:19:05 -0700
    Engine • revision cdbeda788a
    Tools • Dart 3.0.6 • DevTools 2.23.1

3 - Instalando Android SDK
-------------
Para compilar a aplicação para o ambiente Android, é necessário ter algumas versões do Android SDK (versões 10, 11, 12 e 13).

Para instalar as mesmas sem necessidade do Android Studio é necessário utilizar a ferramenta "SDKManager" disponivel no pacote "Command-line tools", segue instruções para instalação:

- Realizar download do Command-line tools ([aqui](https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip"aqui")).
- Extrair para local de preferencia (costumo usar C:\SDKs).
- Adicionar o diretório 'bin' ao PATH do sistema (C:\SDKs\cmdline-tools\bin).

Para verificar se a instalação foi bem sucedida, abra o prompt de comando e digite o seguinte comando:

`sdkmanager --version --sdk_root="C:\SDKs\android"`

O retorno deverá ser o seguinte:

`9.0`

Se a instalação ocorreu normalmente, agora é hora de instalar os pacotes de SDK com os seguintes comandos:

`sdkmanager --install "platforms;android-33" --sdk_root="C:\SDKs\android"`
`sdkmanager --install "sources;android-33" --sdk_root="C:\SDKs\android"`
`sdkmanager --install "platforms;android-31" --sdk_root="C:\SDKs\android"`
`sdkmanager --install "platforms;android-30" --sdk_root="C:\SDKs\android"`
`sdkmanager --install "platforms;android-29" --sdk_root="C:\SDKs\android"`

4 - Compilando a aplicação
-------------
Tendo todos os requisitos instalados podemos iniciar a compilação para o ambiente Android, após o download do código-fonte da aplicação podemos executar os seguintes comandos na pasta raiz do projeto:

`flutter config --android-sdk C:\SDKs\android`
`flutter build apk`

Após a compilação concluir com sucesso, o apk estará disponivel no seguinte diretório:

`build\app\outputs\flutter-apk\app-release.apk`