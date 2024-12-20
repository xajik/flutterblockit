import 'dart:async';

import 'package:flutterblockit/di/usecase/posts_use_case.dart';

import 'api/api_service.dart';
import 'db/db.dart';
import 'usecase/user_session_use_case.dart';
import 'analytics/app_analytics.dart';
import 'analytics/firebase_analytics.dart';
import 'analytics/amplitude_analytics.dart';

class ApplicationDependency {
  final ApiService apiService;
  final Database database;
  final UserSessionUseCase userSessionUsecase;
  final PostsUseCase postsUseCase;
  final AppAnalytics appAnalytics;
  // final FirebaseService firebase; //TODO: Update
  final AmplitudeService amplitude;

  ApplicationDependency({
    required this.apiService,
    required this.database,
    required this.userSessionUsecase,
    required this.postsUseCase,
    required this.appAnalytics,
    // required this.firebase, //TODO: Update
    required this.amplitude,
  });

  static Future<ApplicationDependency> create() async {
    final StreamController<String?> sessionStream =
        StreamController<String>.broadcast();

    final StreamController<bool> unauthorizedStream =
        StreamController<bool>.broadcast();

    final api = await ApiServiceFactory.create(
      sessionStream.stream,
      unauthorizedStream,
    );

    final db = await Database.crete();
    await db.session.sessionStream(sessionStream);

    // final firebase = await FirebaseService.create(); //TODO: Update; Create lib/firebase_options.dart via Firebase CLI
    final amplitude = await AmplitudeService.create();
    final analytics = AppAnalyticsImpl([
      amplitude,
      // firebase,  //TODO: Update
    ]);

    final userSession = UserSessionUseCase(
      db.user,
      db.session,
      api.userApi,
      api.sessionApi,
      analytics,
    );

    userSession.start(unauthorizedStream.stream);

    final postsUseCase = PostsUseCase(
      api.postApi,
      db.post,
    );

    return ApplicationDependency(
      apiService: api,
      database: db,
      userSessionUsecase: userSession,
      postsUseCase: postsUseCase,
      appAnalytics: analytics,
      // firebase: firebase, //TODO: Remove Comment
      amplitude: amplitude,
    );
  }
}
