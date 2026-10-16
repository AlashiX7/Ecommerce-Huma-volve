import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/details/cubit/product_details_cubit.dart';
import '../../features/details/screens/product_details_screen.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_product_by_id.dart';
import '../../features/main_navigation/screens/main_navigation_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/products/:id',
      pageBuilder: (context, state) {
        final productId = int.tryParse(state.pathParameters['id'] ?? '');
        if (productId == null || productId <= 0) {
          return MaterialPage<void>(
            key: state.pageKey,
            child: const InvalidProductLinkScreen(),
          );
        }

        return CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 500),
          child: BlocProvider(
            create: (context) => ProductDetailsCubit(
              GetProductById(context.read<HomeRepository>()),
            )..loadProduct(productId),
            child: ProductDetailsScreen(productId: productId),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => const InvalidProductLinkScreen(),
);

class InvalidProductLinkScreen extends StatelessWidget {
  const InvalidProductLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This product link is invalid.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to the app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
