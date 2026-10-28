import '../../engine/koan.dart';
import 'async_ui.dart';
import 'box_model.dart';
import 'constraints.dart';
import 'flex.dart';
import 'gestures.dart';
import 'implicit_animations.dart';
import 'lists_scrolling.dart';
import 'navigation.dart';
import 'row_column.dart';
import 'stack.dart';
import 'state.dart';
import 'text_and_theme.dart';
import 'widgets.dart';

final flutterWay = Way(
  id: 'flutter',
  title: const Tr('The Way of Flutter', 'Jalan Flutter'),
  tagline: const Tr(
    'Widgets, layout and state: see every answer come alive.',
    'Widget, tata letak, dan state: lihat setiap jawaban menjadi hidup.',
  ),
  categories: [
    widgets,
    rowColumn,
    flex,
    boxModel,
    constraints,
    stack,
    state,
    textAndTheme,
    listsScrolling,
    gestures,
    implicitAnimations,
    navigation,
    asyncUi,
  ],
);
