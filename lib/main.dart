import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterblockit/di/analytics/amplitude_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'di/app_di.dart';
import 'screens/_greenfield/greenfield_bloc.dart';
import 'screens/_greenfield/greenfield_widget.dart';
import 'screens/home/connectivity_bloc.dart';
import 'utils/theme_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final di = await ApplicationDependency.create();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  runApp(createApp(di));
}

Widget createApp(ApplicationDependency di) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: di.userSessionUsecase),
      RepositoryProvider.value(value: di.postsUseCase),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>(
          create: (context) => ConnectivityBloc(Connectivity()),
        ),
        BlocProvider(create: (context) => GreenfieldBloc()),
        // BlocProvider<UserSessionBloc>(
        //   lazy: false,
        //   create: (context) => UserSessionBloc(di.userSessionUsecase)
        //     ..add(HomeUserSessionInitEvent()),
        // ),
      ],
      child: MaterialApp(
        title: 'TODO: Update',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.createTheme(),
        home: const GreenfieldScreenWidget(),
        onGenerateRoute: _getRoutes(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          AmplitudeNavigatorObserver(di.amplitude),
          // di.firebase.observer, //TODO: Update
        ],
      ),
    ),
  );
}

RouteFactory _getRoutes() => (settings) {
      Widget? widget;
      final args = settings.arguments as Map<String, dynamic>?;
      switch (settings.name) {
        case GreenfieldScreenWidget.route:
          widget = const GreenfieldScreenWidget();
          break;
      }
      if (widget == null) {
        assert(false, 'Need to implement ${settings.name}');
        return null;
      } else {
        return MaterialPageRoute(
          builder: (context) {
            return widget!;
          },
        );
      }
    };
