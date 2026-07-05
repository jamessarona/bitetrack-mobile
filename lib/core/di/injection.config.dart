// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bitetrack/core/network/dio_client.dart' as _i865;
import 'package:bitetrack/core/storage/token_storage.dart' as _i311;
import 'package:bitetrack/core/theme/theme_cubit.dart' as _i658;
import 'package:bitetrack/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i806;
import 'package:bitetrack/features/auth/data/repositories/auth_repository_impl.dart'
    as _i920;
import 'package:bitetrack/features/auth/data/services/google_sign_in_service.dart'
    as _i584;
import 'package:bitetrack/features/auth/domain/repositories/auth_repository.dart'
    as _i642;
import 'package:bitetrack/features/auth/domain/usecases/auth_usecases.dart'
    as _i108;
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart'
    as _i1041;
import 'package:bitetrack/features/business/data/datasources/business_remote_datasource.dart'
    as _i932;
import 'package:bitetrack/features/business/data/repositories/business_repository.dart'
    as _i490;
import 'package:bitetrack/features/business/data/services/live_selling_location_service.dart'
    as _i105;
import 'package:bitetrack/features/discover/data/discover_map_cache.dart'
    as _i796;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i658.ThemeCubit>(() => _i658.ThemeCubit());
    gh.lazySingleton<_i584.GoogleSignInService>(
      () => _i584.GoogleSignInService(),
    );
    gh.lazySingleton<_i796.DiscoverMapCache>(() => _i796.DiscoverMapCache());
    gh.lazySingleton<_i311.TokenStorage>(
      () => _i311.TokenStorage(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i865.DioClient>(
      () => _i865.DioClient(gh<_i311.TokenStorage>()),
    );
    gh.lazySingleton<_i806.AuthRemoteDataSource>(
      () => _i806.AuthRemoteDataSource(gh<_i865.DioClient>()),
    );
    gh.lazySingleton<_i932.BusinessRemoteDataSource>(
      () => _i932.BusinessRemoteDataSource(gh<_i865.DioClient>()),
    );
    gh.lazySingleton<_i490.BusinessRepository>(
      () => _i490.BusinessRepository(gh<_i932.BusinessRemoteDataSource>()),
    );
    gh.lazySingleton<_i105.LiveSellingLocationService>(
      () => _i105.LiveSellingLocationService(gh<_i490.BusinessRepository>()),
    );
    gh.lazySingleton<_i642.AuthRepository>(
      () => _i920.AuthRepositoryImpl(
        gh<_i806.AuthRemoteDataSource>(),
        gh<_i311.TokenStorage>(),
        gh<_i584.GoogleSignInService>(),
      ),
    );
    gh.factory<_i108.LoginUseCase>(
      () => _i108.LoginUseCase(gh<_i642.AuthRepository>()),
    );
    gh.factory<_i108.RegisterUseCase>(
      () => _i108.RegisterUseCase(gh<_i642.AuthRepository>()),
    );
    gh.factory<_i108.GetCurrentUserUseCase>(
      () => _i108.GetCurrentUserUseCase(gh<_i642.AuthRepository>()),
    );
    gh.factory<_i108.LogoutUseCase>(
      () => _i108.LogoutUseCase(gh<_i642.AuthRepository>()),
    );
    gh.factory<_i108.UpdateThemePreferenceUseCase>(
      () => _i108.UpdateThemePreferenceUseCase(gh<_i642.AuthRepository>()),
    );
    gh.factory<_i108.UpdateProfileUseCase>(
      () => _i108.UpdateProfileUseCase(gh<_i642.AuthRepository>()),
    );
    gh.factory<_i108.GoogleSignInUseCase>(
      () => _i108.GoogleSignInUseCase(
        gh<_i642.AuthRepository>(),
        gh<_i584.GoogleSignInService>(),
      ),
    );
    gh.factory<_i1041.AuthBloc>(
      () => _i1041.AuthBloc(
        getCurrentUser: gh<_i108.GetCurrentUserUseCase>(),
        login: gh<_i108.LoginUseCase>(),
        register: gh<_i108.RegisterUseCase>(),
        logout: gh<_i108.LogoutUseCase>(),
        googleSignIn: gh<_i108.GoogleSignInUseCase>(),
      ),
    );
    return this;
  }
}
