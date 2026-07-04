// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bitetrack/core/network/dio_client.dart' as _i5;
import 'package:bitetrack/core/storage/token_storage.dart' as _i3;
import 'package:bitetrack/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i6;
import 'package:bitetrack/features/auth/data/repositories/auth_repository_impl.dart'
    as _i8;
import 'package:bitetrack/features/auth/domain/repositories/auth_repository.dart'
    as _i7;
import 'package:bitetrack/features/auth/domain/usecases/auth_usecases.dart'
    as _i9;
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart'
    as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i4;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.TokenStorage>(
        () => _i3.TokenStorage(gh<_i4.SharedPreferences>()));
    gh.lazySingleton<_i5.DioClient>(
        () => _i5.DioClient(gh<_i3.TokenStorage>()));
    gh.lazySingleton<_i6.AuthRemoteDataSource>(
        () => _i6.AuthRemoteDataSource(gh<_i5.DioClient>()));
    gh.lazySingleton<_i7.AuthRepository>(() => _i8.AuthRepositoryImpl(
          gh<_i6.AuthRemoteDataSource>(),
          gh<_i3.TokenStorage>(),
        ));
    gh.factory<_i9.GetCurrentUserUseCase>(
        () => _i9.GetCurrentUserUseCase(gh<_i7.AuthRepository>()));
    gh.factory<_i9.LoginUseCase>(
        () => _i9.LoginUseCase(gh<_i7.AuthRepository>()));
    gh.factory<_i9.LogoutUseCase>(
        () => _i9.LogoutUseCase(gh<_i7.AuthRepository>()));
    gh.factory<_i9.RegisterUseCase>(
        () => _i9.RegisterUseCase(gh<_i7.AuthRepository>()));
    gh.factory<_i10.AuthBloc>(() => _i10.AuthBloc(
          getCurrentUser: gh<_i9.GetCurrentUserUseCase>(),
          login: gh<_i9.LoginUseCase>(),
          register: gh<_i9.RegisterUseCase>(),
          logout: gh<_i9.LogoutUseCase>(),
        ));
    return this;
  }
}
