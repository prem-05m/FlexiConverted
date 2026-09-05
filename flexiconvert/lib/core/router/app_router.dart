import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/route_constants.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/biometric_unlock_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/queue/presentation/screens/conversion_queue_screen.dart';
import '../../features/queue/presentation/screens/completed_screen.dart';
import '../../features/pdf/presentation/screens/pdf_dashboard_screen.dart';
import '../../features/pdf/presentation/screens/base_pdf_tool_screen.dart';
import '../../features/pdf/presentation/screens/edit_pdf_screen.dart';
import '../../features/pdf/presentation/screens/image_to_pdf_screen.dart';
import '../../features/pdf/presentation/screens/pdf_to_image_screen.dart';
import '../../features/pdf/presentation/screens/sign_pdf_screen.dart';
import '../../features/pdf/presentation/screens/redact_pdf_screen.dart';
import '../../features/pdf/domain/models/pdf_task_model.dart';
import '../../features/image/presentation/screens/image_dashboard_screen.dart';
import '../../features/image/presentation/screens/base_image_tool_screen.dart';
import '../../features/image/presentation/screens/image_editor_dashboard_screen.dart';
import '../../features/image/domain/models/image_task_model.dart';
import '../../features/document/presentation/screens/document_dashboard_screen.dart';
import '../../features/document/presentation/screens/base_document_tool_screen.dart';
import '../../features/document/domain/models/document_task_model.dart';
import '../../features/video/presentation/screens/video_dashboard_screen.dart';
import '../../features/video/presentation/screens/base_video_tool_screen.dart';
import '../../features/video/domain/models/video_task_model.dart';
import '../../features/audio/presentation/screens/audio_dashboard_screen.dart';
import '../../features/audio/presentation/screens/base_audio_tool_screen.dart';
import '../../features/audio/domain/models/audio_task_model.dart';
import '../../features/archive/presentation/screens/archive_dashboard_screen.dart';
import '../../features/archive/presentation/screens/base_archive_tool_screen.dart';
import '../../features/archive/domain/models/archive_task_model.dart';
import '../../features/qr/presentation/screens/qr_dashboard_screen.dart';
import '../../features/qr/presentation/screens/base_qr_tool_screen.dart';
import '../../features/qr/presentation/screens/qr_generator_screen.dart';
import '../../features/qr/presentation/screens/scanner_screen.dart';
import '../../features/qr/domain/models/qr_task_model.dart';
import '../../features/files/presentation/screens/file_dashboard_screen.dart';
import '../../features/files/presentation/screens/base_file_tool_screen.dart';
import '../../features/files/presentation/screens/file_manager_screen.dart';
import '../../features/files/domain/models/file_task_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isBiometricEnabled = ref.watch(isBiometricEnabledProvider).value ?? false;
  final isBiometricUnlocked = ref.watch(biometricUnlockProvider);

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isGoingToLogin = state.matchedLocation == RouteConstants.login;
      final isGoingToSignUp = state.matchedLocation == RouteConstants.signUp;
      final isGoingToForgot = state.matchedLocation == RouteConstants.forgotPassword;
      final isGoingToSplash = state.matchedLocation == RouteConstants.splash;
      final isGoingToOnboarding = state.matchedLocation == RouteConstants.onboarding;

      if (authState.isLoading) return null;

      // Handle onboarding logic here (simplified for now, usually checks SharedPreferences)
      
      if (!isAuth && !isGoingToLogin && !isGoingToSignUp && !isGoingToForgot && !isGoingToSplash && !isGoingToOnboarding) {
        return RouteConstants.login;
      }
      
      if (isAuth) {
        if (isBiometricEnabled && !isBiometricUnlocked) {
          if (state.matchedLocation != RouteConstants.biometricUnlock) {
            return RouteConstants.biometricUnlock;
          }
        } else if (isGoingToLogin || isGoingToSignUp || isGoingToSplash) {
          return RouteConstants.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        name: RouteConstants.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.signUp,
        name: RouteConstants.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: RouteConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteConstants.biometricUnlock,
        name: RouteConstants.biometricUnlock,
        builder: (context, state) => const BiometricUnlockScreen(),
      ),
      GoRoute(
        path: RouteConstants.home,
        name: RouteConstants.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'edit_profile',
            name: 'edit_profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: RouteConstants.search,
            name: RouteConstants.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: RouteConstants.pdf,
            name: RouteConstants.pdf,
            builder: (context, state) => const PdfDashboardScreen(),
            routes: PdfToolType.values.map((tool) {
              return GoRoute(
                path: tool.name,
                name: 'pdf_${tool.name}',
                builder: (context, state) {
                  if (tool == PdfToolType.editPdf) {
                    return const EditPdfScreen();
                  }
                  if (tool == PdfToolType.addSignature) {
                    return const SignPdfScreen();
                  }
                  if (tool == PdfToolType.redactPdf) {
                    return const RedactPdfScreen();
                  }
                  return BasePdfToolScreen(toolType: tool);
                },
              );
            }).toList(),
          ),
          GoRoute(
            path: RouteConstants.image,
            name: RouteConstants.image,
            builder: (context, state) => const ImageDashboardScreen(),
            routes: ImageToolType.values.map((tool) {
              return GoRoute(
                path: tool.name,
                name: 'image_${tool.name}',
                builder: (context, state) {
                  if (tool == ImageToolType.editImage ||
                      tool == ImageToolType.crop ||
                      tool == ImageToolType.rotate ||
                      tool == ImageToolType.flip ||
                      tool == ImageToolType.adjust ||
                      tool == ImageToolType.addText ||
                      tool == ImageToolType.addWatermark ||
                      tool == ImageToolType.blur ||
                      tool == ImageToolType.pixelate) {
                    return const ImageEditorDashboardScreen();
                  }
                  return BaseImageToolScreen(toolType: tool);
                },
              );
            }).toList(),
          ),
          GoRoute(
            path: RouteConstants.document,
            name: RouteConstants.document,
            builder: (context, state) => const DocumentDashboardScreen(),
            routes: DocumentToolType.values.map((tool) {
              return GoRoute(
                path: tool.name,
                name: 'document_${tool.name}',
                builder: (context, state) {
                  if (tool == DocumentToolType.jpgToPdf) {
                    return const ImageToPdfScreen();
                  }
                  if (tool == DocumentToolType.pdfToJpg) {
                    return const PdfToImageScreen();
                  }
                  return BaseDocumentToolScreen(toolType: tool);
                },
              );
            }).toList(),
          ),
          GoRoute(
            path: RouteConstants.video,
            name: RouteConstants.video,
            builder: (context, state) => const VideoDashboardScreen(),
            routes: VideoToolType.values.map((tool) {
              return GoRoute(
                path: tool.name,
                name: 'video_${tool.name}',
                builder: (context, state) => BaseVideoToolScreen(toolType: tool),
              );
            }).toList(),
          ),
          GoRoute(
            path: RouteConstants.audio,
            name: RouteConstants.audio,
            builder: (context, state) => const AudioDashboardScreen(),
            routes: [
              GoRoute(
                path: '${RouteConstants.audio}/tool',
                builder: (context, state) {
                  final toolType = state.extra as AudioToolType;
                  return BaseAudioToolScreen(toolType: toolType);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteConstants.archive,
            name: RouteConstants.archive,
            builder: (context, state) => const ArchiveDashboardScreen(),
            routes: [
              GoRoute(
                path: 'tool',
                builder: (context, state) {
                  final toolType = state.extra as ArchiveToolType;
                  return BaseArchiveToolScreen(toolType: toolType);
                },
              ),
            ]
          ),
          GoRoute(
            path: RouteConstants.qr,
            name: RouteConstants.qr,
            builder: (context, state) => const QrDashboardScreen(),
            routes: [
              GoRoute(
                path: 'scan',
                builder: (context, state) => const ScannerScreen(),
              ),
              GoRoute(
                path: 'tool',
                builder: (context, state) {
                  final toolType = state.extra as QrToolType;
                  if (toolType == QrToolType.generate) {
                    return const QrGeneratorScreen();
                  }
                  return BaseQrToolScreen(toolType: toolType);
                },
              ),
            ]
          ),
          GoRoute(
            path: RouteConstants.files,
            name: RouteConstants.files,
            builder: (context, state) => const FileDashboardScreen(),
            routes: [
              GoRoute(
                path: 'manager',
                builder: (context, state) => const FileManagerScreen(),
              ),
              GoRoute(
                path: 'tool',
                builder: (context, state) {
                  final toolType = state.extra as FileToolType;
                  return BaseFileToolScreen(toolType: toolType);
                },
              ),
            ]
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.history,
        name: RouteConstants.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RouteConstants.favorites,
        name: RouteConstants.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        name: RouteConstants.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.about,
        name: RouteConstants.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RouteConstants.privacyPolicy,
        name: RouteConstants.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.queue,
        name: RouteConstants.queue,
        builder: (context, state) => const ConversionQueueScreen(),
      ),
      GoRoute(
        path: RouteConstants.completed,
        name: RouteConstants.completed,
        builder: (context, state) => const CompletedScreen(),
      ),
    ],
  );
});

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
}
