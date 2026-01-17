# Fortune Zé

## Screenshots

As imagens a seguir mostram a interface principal (Home) e a tela de Conta. As imagens são carregadas a partir dos arquivos do repositório em `assets/img/`.

<p align="center">
  <img src="assets/img/image.png" alt="Home" width="48%" />
  <img src="assets/img/logo.png" alt="Conta" width="48%" />
</p>

## Descrição

Fortune Zé é um aplicativo de slot machine para diversão, implementado em
Flutter com arquitetura MVVM e Provider para gerenciamento de estado. O app
simula apostas com um tabuleiro 3x3 de símbolos, animações de spin, efeitos
sonoros e persistência local via SQLite.

## Principais recursos

- Máquina caça-níqueis 3x3 com animações e destaque das combinações vencedoras.
- Visual que destaca as células vencedoras e reduz as não correspondentes.
- Sistema de conta com saldo em BRL (pt_BR) e histórico de depósitos.
- Modal de saque com aviso profissional quando o saldo for insuficiente.
- Reprodução de áudio para spin e efeitos de vitória/derrota.

## Arquitetura e tecnologias

- Flutter (Dart)
- MVVM com Provider (ChangeNotifier)
- sqflite para persistência local (com fallback em memória)
- audioplayers para reprodução de sons
- intl para formatação monetária

## Arquivos importantes

- `lib/main.dart` - ponto de entrada e scaffold principal com navegação por abas
- `lib/views/home_screen.dart` - tela principal com a máquina e controles de aposta
- `lib/views/account_screen.dart` - tela de conta, saldo, chave PIX mock e histórico
- `lib/views/slot_view.dart` - componente da matriz 3x3 com animações e áudio
- `lib/viewmodels/slot_viewmodel.dart` - lógica de spin, probabilidades e prêmios
- `lib/viewmodels/account_viewmodel.dart` - gerenciamento de saldo e histórico
- `lib/services/db_service.dart` - wrapper simples sobre sqflite
- `assets/img/logo.png` - imagem usada para gerar os ícones do app
- `assets/sounds/` - sons: `load.mp3`, `jack.mp3`, `fail.mp3`

## Instalação e execução

Pré-requisitos:

- Flutter instalado (SDK compatível com >= 3.8.1)
- Emulador Android/iOS ou dispositivo conectado

Passos:

1. Instale dependências:

```bash
flutter pub get
```

2. (Opcional) Gere os ícones a partir de `assets/img/logo.png`:

```bash
flutter pub run flutter_launcher_icons:main
```

3. Rode o app em modo debug:

```bash
flutter run
```

4. Gere APK de release:

```bash
flutter build apk --release
```

## Testes e análise

- Rode análise estática com `flutter analyze`.
- Testes de widget/unit podem ser colocados em `test/`.

## Notas de desenvolvimento

- O armazenamento usa um esquema simples key-value. Para histórico mais
  robusto, considere migrar para tabelas dedicadas no SQLite.
- Este aplicativo é para demonstração e não realiza transações financeiras
  reais.

## Contribuição

Contribuições são bem-vindas. Para alterações significativas, abra uma issue
descrevendo a proposta antes de submeter um pull request.

## Licença

Fornecido conforme está, para fins de demonstração.
