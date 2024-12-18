import 'dart:async';
import 'dart:math';

import 'package:cattyled_app/widgets/text_animated.dart';
import 'package:flutter/material.dart';

class TextGreeting extends StatefulWidget {
  const TextGreeting({super.key});

  @override
  State<TextGreeting> createState() => _TextGreetingState();
}

class _TextGreetingState extends State<TextGreeting> {
  static final List<List<String>> _greetingPhrases = [
    [
      'Отличного дня!',
      'Доброе утро!',
      'Как насчёт кофе?',
      'Кофе в помощь',
      'Ещё один день...',
      'Не спать! Не спать!',
      'Мяу!',
      'Кто здесь?',
    ],
    [
      'Терпения!',
      'Добрый день!',
      'Мяу!',
      'Спасите!',
      'Перерыв!',
      'Кто здесь?',
    ],
    [
      'Время отдыхать!',
      'Добрый вечер!',
      'Наслаждайся вечером!',
      'Мяу!',
      'Перерыв!',
      'Спасите!',
      'Кто здесь?',
    ],
    [
      'Доброй ночи!',
      'Ещё не спишь?',
      'Считаю котов...',
      'Кто здесь?',
      'Zzzzz',
      'Night-night',
      '🌙',
    ],
  ];

  int periodIndex = 0;
  String greeting = "";

  @override
  void initState() {
    super.initState();
    _updateGreeting();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TextAnimated(
      greeting,
      periodIndex,
      style: textTheme.headlineMedium,
    );
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    final random = Random();

    setState(() {
      if (hour >= 5 && hour < 12) {
        periodIndex = 0;
      } else if (hour >= 12 && hour < 18) {
        periodIndex = 1;
      } else if (hour >= 18 && hour < 23) {
        periodIndex = 2;
      } else {
        periodIndex = 3;
      }

      final phrases = _greetingPhrases[periodIndex];
      greeting = phrases[random.nextInt(phrases.length)];
    });

    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    final timeToNextHour = nextHour.difference(now);
    Timer(timeToNextHour, _updateGreeting);
  }
}
