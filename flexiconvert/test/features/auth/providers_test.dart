import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flexiconvert/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flexiconvert/features/auth/presentation/providers/auth_providers.dart';

class MockUser extends Mock implements User {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    
    // We stub the stream so the provider has an initial state.
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(null));

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('authStateProvider emits initial unauthenticated state', () async {
    final authState = container.read(authStateProvider);
    expect(authState.isLoading, isTrue); // initially it might be loading due to StreamProvider
    
    // Wait for stream to emit
    await Future.delayed(Duration.zero);
    
    final value = container.read(authStateProvider).value;
    expect(value, isNull);
  });

  test('authStateProvider emits authenticated user', () async {
    final mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('123');
    when(() => mockUser.email).thenReturn('test@test.com');
    
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(mockUser));

    final testContainer = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );

    // Wait for stream to emit
    final value = await testContainer.read(authStateProvider.future);
    
    expect(value, isNotNull);
    expect(value?.uid, '123');
    expect(value?.email, 'test@test.com');
  });

  test('logout calls repository logout', () async {
    when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
    
    await container.read(authRepositoryProvider).logout();
    
    verify(() => mockAuthRepository.logout()).called(1);
  });
}
