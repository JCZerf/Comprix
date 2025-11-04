# 🛒 Market Express

**Market Express** é um aplicativo móvel completo desenvolvido em Flutter para gerenciamento inteligente de listas de compras e controle de preços. O app oferece uma experiência moderna e intuitiva para organizar suas compras, acompanhar variações de preços e manter um histórico detalhado dos seus gastos.

## 📱 Capturas de Tela

*Em breve - capturas de tela do aplicativo*

## ✨ Funcionalidades Principais

### 🏠 **Gestão de Produtos**
- ✅ **Lista de Produtos**: Visualize todos os seus produtos em uma interface moderna e organizada
- ✅ **Busca Inteligente**: Encontre produtos rapidamente usando a barra de pesquisa em tempo real
- ✅ **Adicionar Produtos**: Cadastre novos produtos com nome, preço, quantidade, descrição e categoria
- ✅ **Editar Produtos**: Modifique informações de produtos existentes
- ✅ **Categorização**: Organize produtos por categorias predefinidas
- ✅ **Controle de Preços**: Acompanhe o histórico de preços de cada produto

### 🛍️ **Sistema de Compras**
- ✅ **Criar Lista de Compras**: Monte listas personalizadas selecionando produtos existentes
- ✅ **Modo Shopping**: Interface otimizada para usar durante as compras
- ✅ **Marcar Items**: Marque produtos como adicionados ao carrinho
- ✅ **Cálculo Automático**: Total da compra calculado automaticamente
- ✅ **Histórico de Compras**: Mantenha um registro completo de todas as suas compras

### 📊 **Controle Financeiro**
- ✅ **Histórico de Preços**: Acompanhe a evolução dos preços dos produtos
- ✅ **Cálculos Precisos**: Sistema de preços em centavos para máxima precisão
- ✅ **Relatórios**: Visualize gastos por compra e período

### 🎨 **Interface e Experiência**
- ✅ **Design Moderno**: Interface clean e intuitiva seguindo Material Design
- ✅ **Navegação por Abas**: Acesso rápido entre lista de produtos e histórico de compras
- ✅ **Feedback Visual**: Animações e transições suaves
- ✅ **Estados de Carregamento**: Indicadores visuais durante operações
- ✅ **Confirmações**: Diálogos de confirmação para ações críticas

## 🛠️ Tecnologias Utilizadas

### **Frontend**
- **Flutter** (SDK ^3.8.1) - Framework multiplataforma
- **Dart** - Linguagem de programação
- **Material Design** - Sistema de design do Google

### **Gerenciamento de Estado**
- **Provider** (^6.1.5+1) - Padrão de arquitetura reativa

### **Banco de Dados**
- **SQLite** via **sqflite** (^2.4.2) - Banco de dados local

### **Dependências Principais**
- **intl** (^0.19.0) - Formatação de datas e números
- **currency_text_input_formatter** (^2.1.10) - Formatação de valores monetários
- **flutter_launcher_icons** (^0.14.4) - Geração de ícones do app

## 🏗️ Arquitetura do Projeto

```
lib/
├── controllers/          # Gerenciamento de estado
│   ├── ItemMarketController.dart
│   ├── ItemPriceController.dart
│   └── PurchasesController.dart
├── db/                   # Camada de dados
│   └── DbHelper.dart
├── models/               # Modelos de dados
│   ├── ItemMarketModel.dart
│   └── PurchaseModel.dart
├── screens/              # Telas do aplicativo
│   ├── HomePage.dart
│   ├── AddItemPage.dart
│   ├── ItemDetailsPage.dart
│   ├── PriceUpdatePage.dart
│   ├── CreatePurchasePage.dart
│   ├── PurchasesListPage.dart
│   ├── SelectItemPage.dart
│   ├── Shopping_page.dart
│   └── MainNavigation.dart
├── services/             # Serviços auxiliares
│   └── LoadCategories.dart
├── utils/                # Utilitários
│   ├── price_helper.dart
│   └── watermark_widget.dart
├── widgets/              # Componentes reutilizáveis
│   └── price_form_field.dart
└── main.dart            # Ponto de entrada
```

### **Padrões Utilizados**
- **MVC (Model-View-Controller)**: Separação clara de responsabilidades
- **Provider Pattern**: Gerenciamento de estado reativo
- **Repository Pattern**: Abstração da camada de dados
- **Singleton Pattern**: Instância única do helper de banco de dados

## 🚀 Como Executar o Projeto

### **Pré-requisitos**
- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / VS Code
- Emulador Android ou dispositivo físico

### **Instalação**

1. **Clone o repositório**
```bash
git clone https://github.com/JCZerf/Market_Express.git
cd Market_Express
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o aplicativo**
```bash
flutter run
```

### **Build para Produção**

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

## 💾 Banco de Dados

O aplicativo utiliza SQLite com as seguintes tabelas:

### **Tabela `items`**
```sql
CREATE TABLE items(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  price REAL,
  priceCentavos INTEGER,
  quantity INTEGER,
  description TEXT,
  category TEXT
)
```

### **Tabela `purchases`**
```sql
CREATE TABLE purchases(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  date TEXT,
  itemIds TEXT,
  totalValue REAL,
  isAdded TEXT
)
```

### **Tabela `item_prices`**
```sql
CREATE TABLE item_prices(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  itemId INTEGER,
  price REAL,
  date TEXT
)
```

## 🎯 Funcionalidades Detalhadas

### **Tela Principal (HomePage)**
- Lista todos os produtos cadastrados
- Barra de pesquisa com filtro em tempo real
- Cartões com informações do produto (nome, descrição, categoria, quantidade, preço)
- Botão para adicionar novos produtos
- Opção de excluir produtos com confirmação

### **Adicionar/Editar Produto**
- Formulário completo com validação
- Campos: nome, preço, quantidade, descrição, categoria
- Seleção de categoria a partir de lista predefinida
- Formatação automática de valores monetários

### **Lista de Compras**
- Criação de listas personalizadas
- Seleção de produtos existentes
- Cálculo automático do total
- Data e nome personalizáveis

### **Modo Shopping**
- Interface otimizada para uso durante compras
- Marcar/desmarcar itens como adicionados
- Visualização clara do progresso
- Opções para editar ou remover itens da lista

### **Histórico de Preços**
- Acompanhamento de variações de preço
- Registro automático ao atualizar preços
- Visualização cronológica

## 🔧 Configurações

### **Categorias de Produtos**
As categorias são carregadas de `assets/category.JSON`:
```json
[
  "Alimentação",
  "Bebidas",
  "Higiene",
  "Limpeza",
  "Outros"
]
```

### **Ícone do App**
- Localização: `assets/img/logo.png`
- Configuração automática para Android e iOS via `flutter_launcher_icons`

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Roadmap

### **Próximas Funcionalidades**
- [ ] **Sincronização em Nuvem**: Backup e sincronização entre dispositivos
- [ ] **Compartilhamento**: Compartilhar listas de compras com outros usuários
- [ ] **Notificações**: Lembretes para compras planejadas
- [ ] **Análise de Gastos**: Gráficos e relatórios de gastos
- [ ] **Modo Escuro**: Tema escuro para o aplicativo
- [ ] **Exportação**: Exportar listas e relatórios em PDF/Excel

### **Melhorias Técnicas**
- [ ] **Testes Unitários**: Cobertura completa de testes
- [ ] **Testes de Widget**: Testes de interface
- [ ] **CI/CD**: Pipeline de integração contínua
- [ ] **Performance**: Otimizações de performance
- [ ] **Acessibilidade**: Melhorias de acessibilidade

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**JCarlos** - [@JCZerf](https://github.com/JCZerf)

---

**Market Express** - *Simplificando suas compras, organizando sua vida* 🛒✨
