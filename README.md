# Comprix

Aplicativo Flutter para gestão de itens, execução de compras e análise de variação de preços.

Versão atual do app: `2.2.0`.

## Escopo do produto

O aplicativo está organizado em três áreas principais:

- `Lista` (`HomePage`): cadastro e manutenção de itens.
- `Compras` (`PurchasesListPage` + `Shopping_page`): criação de listas e fluxo de compra no mercado.
- `Análise` (`AnalysisPage`): acompanhamento de histórico e variação de preços por item.

## Funcionalidades

### Cadastro de itens

- Cadastro, edição e remoção de itens.
- Campos: nome, quantidade, preço, descrição e categoria.
- Feedback de duplicidade durante digitação do nome.
- Busca normalizada (case-insensitive e sem sensibilidade a acentos).
- Sugestões de busca com controle de abertura/fechamento:
  - fecha ao confirmar busca
  - fecha ao tocar em sugestão
  - reabre ao editar o texto
- Ordenação na lista principal:
  - Alfabética (padrão)
  - Por categoria
  - Por preço (maior primeiro)
  - Por quantidade (maior primeiro)

### Fluxo de compras

- Criação de compra com base em itens já cadastrados.
- Inclusão de item na compra por dois caminhos:
  - Selecionar item existente (multi-seleção)
  - Criar novo item
- Tela de shopping com marcação de itens comprados.
- Controle de exibição de itens comprados (mostrar/ocultar).
- Ordenação na tela de shopping:
  - Alfabética
  - Por categoria
- Busca com sugestões dentro da compra.
- Opção de atualizar preço ao concluir item.

### Categorias com preço variável

Itens de categorias voláteis podem ser tratados como “preço na compra”.

Regra implementada em `lib/utils/variable_price_categories.dart`:

- Chaves diretas:
  - `hortifruti`
  - `carnes`
  - `carnes e frios` (compatibilidade legado)
  - `produtos naturais e organicos` (compatibilidade legado)
- Fallback por palavras-chave (`carne`, `frio`, `verdura`, `legume`, `fruta`, etc.).

### Análise de preços

- Seleção de item por pesquisa (sem dropdown).
- Resumo em cards:
  - Produtos monitorados
  - Itens com aumento
  - Itens com queda
  - Itens estáveis
- Métricas por item:
  - Preço inicial
  - Preço atual
  - Diferença acumulada e percentual
- Lista de histórico recente de preços.

## Stack técnica

- Flutter (Dart)
- Provider (gerenciamento de estado)
- SQLite via `sqflite`
- `intl`
- `currency_text_input_formatter`

## Arquitetura

Estrutura em camadas, com separação prática por responsabilidade:

- `models/`: entidades de domínio
- `controllers/`: estado e orquestração (`ChangeNotifier`)
- `db/`: persistência e migração (`DBHelper`)
- `screens/`: composição de telas
- `widgets/`: componentes reutilizáveis
- `utils/`: normalização, formatação, estilo e heurísticas
- `services/`: serviços de apoio (ex.: carga de categorias)

Entrada da aplicação (`main.dart`) usando `MultiProvider` com:

- `MarketItemController`
- `PurchaseController`
- `ItemPriceController`

## Estrutura do repositório

```text
lib/
  controllers/
  db/
  models/
  screens/
  services/
  utils/
  widgets/
  main.dart
assets/
  category.JSON
  img/
```

## Banco de dados

Arquivo responsável: `lib/db/DbHelper.dart`.

- Nome do banco: `market_express.db`
- Versão de schema atual: `5`

Tabelas:

- `items`
  - `id INTEGER PRIMARY KEY AUTOINCREMENT`
  - `name TEXT`
  - `price REAL`
  - `priceCentavos INTEGER`
  - `quantity INTEGER`
  - `description TEXT`
  - `category TEXT`

- `purchases`
  - `id INTEGER PRIMARY KEY AUTOINCREMENT`
  - `name TEXT`
  - `date TEXT`
  - `itemIds TEXT`
  - `totalValue REAL`
  - `isAdded TEXT`

- `item_prices`
  - `id INTEGER PRIMARY KEY AUTOINCREMENT`
  - `itemId INTEGER`
  - `price REAL`
  - `date TEXT`

### Regra de valor monetário

A base usa `priceCentavos` para cálculos de valor com precisão e menor risco de erro por ponto flutuante.

## Categorias atuais

Fonte: `assets/category.JSON`

1. Alimentos
2. Bebidas
3. Hortifruti
4. Carnes
5. Padaria
6. Laticínios e Embutidos
7. Limpeza
8. Higiene e Beleza
9. Casa
10. Pet
11. Outros

Mapeamento de cores em `lib/utils/app_colors.dart`, com compatibilidade para categorias antigas.

## Como executar

### Pré-requisitos

- Flutter SDK compatível com o projeto
- Android Studio ou VS Code
- Emulador Android ou dispositivo físico

### Instalação e execução

```bash
flutter pub get
flutter run
```

## Verificações de qualidade

Análise completa:

```bash
flutter analyze
```

Análise de arquivos específicos:

```bash
flutter analyze lib/screens/HomePage.dart lib/screens/Shopping_page.dart
```

## Build

APK Android:

```bash
flutter build apk --release
```

App Bundle Android:

```bash
flutter build appbundle --release
```

## Versionamento

Versão do aplicativo em `pubspec.yaml`:

```yaml
version: 2.2.0+3
```

Marca d’água de versão na interface em `lib/utils/watermark_widget.dart`.

## Notas de manutenção

- Mantenha comportamento de busca consistente entre telas (`SearchSuggestionsPanel` + controle de abertura/fechamento).
- Ao alterar normalização de busca, revisar `utils/search_normalizer.dart` e `utils/item_search_helper.dart`.
- Ao alterar categorias, revisar em conjunto:
  - `assets/category.JSON`
  - `utils/app_colors.dart`
  - `utils/variable_price_categories.dart`
- Em mudanças de schema, atualizar migração em `DBHelper` e incrementar versão do banco com cuidado.
