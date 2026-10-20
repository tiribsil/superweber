import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('pt', 'BR'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'pt': {
      'app_title': 'SuperWeber',
      'team_members': 'Desenvolvedores: Ti Ribeiro Silvério & Giovanna Vieira Gaeta',
      'login_title': 'Entrar no SuperWeber',
      'select_language': 'Idioma',
      'portuguese': 'Português',
      'english': 'Inglês',
      'play': 'Jogar',
      'settings': 'Configurações',
      'help': 'Ajuda',
      'sign_out': 'Sair',
      'difficulty': 'Dificuldade',
      'easy': 'Fácil',
      'intermediate': 'Intermediário',
      'advanced': 'Avançado',
      'hard': 'Difícil',
      'score': 'Carros Destruídos',
      'hp': 'Vidas',
      'time_remaining': 'Tempo',
      'skip': 'Pular Placa',
      'verify': 'Verificar',
      'clear': 'Limpar',
      'game_over': 'Fim de Jogo!',
      'game_over_desc': 'O Weber perdeu todas as vidas. Tente novamente!',
      'restart': 'Reiniciar Partida',
      'theme_mode': 'Modo de Tema',
      'theme_system': 'Padrão do Sistema',
      'theme_light': 'Claro',
      'theme_dark': 'Escuro',
      'font_size': 'Tamanho da Fonte',
      'font_family': 'Família da Fonte',
      'seed_color': 'Cor Semente do Tema',
      'sound': 'Efeitos Sonoros',
      'sound_on': 'Ligado',
      'sound_off': 'Desligado (Padrão)',
      'help_title': 'Como Jogar o SuperWeber',
      'help_content': 'Você é o Weber, um gato com poderes destrutivos! Ele destrói carros com sua mente resolvendo equações formadas com os 4 dígitos da placa do carro.\n\n'
          '• Arraste os operadores para os slots antes, entre e depois dos dígitos.\n'
          '• É obrigatório inserir ao menos um operador entre cada par de dígitos.\n'
          '• Insira ao menos um sinal de igual (=) para validar a equação.\n'
          '• A equação é válida se o lado esquerdo for igual ao lado direito.\n'
          '• Cuidado: divisões por zero ou valores acima de 10.000 são rejeitados automaticamente.\n'
          '• Resolva antes que o carro colida com o Weber para fazê-lo explodir!\n'
          '• Se o carro atingir o Weber, você perde 1 vida (máximo 9 vidas).',
      'close': 'Fechar',
      'error_div_zero': 'Divisão por zero não é permitida.',
      'error_overflow': 'Resultado excede o limite máximo de 10.000.',
      'error_invalid_eq': 'Equação inválida ou lados desiguais.',
      'error_non_integer_div': 'Divisão não inteira permitida apenas no nível Fácil.',
      'records_title': 'Placas Resolvidas',
      'loading': 'Carregando dados...',
      'no_records': 'Nenhuma placa resolvida ainda.',
    },
    'en': {
      'app_title': 'SuperWeber',
      'team_members': 'Developers: Ti Ribeiro Silvério & Giovanna Vieira Gaeta',
      'login_title': 'Sign in to SuperWeber',
      'select_language': 'Language',
      'portuguese': 'Portuguese',
      'english': 'English',
      'play': 'Play',
      'settings': 'Settings',
      'help': 'Help',
      'sign_out': 'Sign Out',
      'difficulty': 'Difficulty',
      'easy': 'Easy',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'hard': 'Hard',
      'score': 'Cars Destroyed',
      'hp': 'Lives',
      'time_remaining': 'Time',
      'skip': 'Skip Plate',
      'verify': 'Verify',
      'clear': 'Clear',
      'game_over': 'Game Over!',
      'game_over_desc': 'Weber lost all nine lives. Try again!',
      'restart': 'Restart Run',
      'theme_mode': 'Theme Mode',
      'theme_system': 'System Default',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'font_size': 'Font Size',
      'font_family': 'Font Family',
      'seed_color': 'Theme Seed Color',
      'sound': 'Sound Effects',
      'sound_on': 'Enabled',
      'sound_off': 'Muted (Default)',
      'help_title': 'How to Play SuperWeber',
      'help_content': 'You are Weber, a cat with psychic destructive powers! Weber destroys cars with his mind by balancing equations formed from 4-digit license plates.\n\n'
          '• Drag and drop operators into slots before, between, and after digits.\n'
          '• You must insert at least one operator between each consecutive digit pair.\n'
          '• You must include at least one equals sign (=) to win.\n'
          '• The equation is solved when the left-hand side equals the right-hand side.\n'
          '• Note: division by zero or values exceeding 10,000 are rejected automatically.\n'
          '• Solve before the incoming car reaches Weber to explode it!\n'
          '• If a car reaches Weber, you lose 1 life (up to 9 lives).',
      'close': 'Close',
      'error_div_zero': 'Division by zero is not permitted.',
      'error_overflow': 'Result exceeds the maximum limit of 10,000.',
      'error_invalid_eq': 'Invalid equation or sides are not equal.',
      'error_non_integer_div': 'Fractional division is only allowed in Easy mode.',
      'records_title': 'Solved Plates',
      'loading': 'Loading data...',
      'no_records': 'No solved plates yet.',
    },
  };

  String translate(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['pt']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['pt', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
