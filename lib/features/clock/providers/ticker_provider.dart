import 'package:flutter_riverpod/flutter_riverpod.dart';

final tickerProvider = StateProvider<DateTime>((ref) => DateTime.now());
