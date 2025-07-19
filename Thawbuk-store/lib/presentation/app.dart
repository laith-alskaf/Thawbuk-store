import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/dependency_injection.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/cart/cart_bloc.dart';
import 'bloc/theme/theme_cubit.dart';
import 'navigation/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>(),
        ),
        BlocProvider<ProductBloc>(
          create: (_) => getIt<ProductBloc>(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => getIt<CartBloc>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => getIt<ThemeCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            routerConfig: getIt<AppRouter>().router,
            debugShowCheckedModeBanner: false,
            title: 'ثوبك',
            
            // دعم اللغات والاتجاه
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],
            
            // التصميم
            theme: themeState.themeData,
          );
        },
      ),
    );
  }
}