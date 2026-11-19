import 'dart:convert';
import 'dart:io';

import 'package:barakah_time/core/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory tmp;
  late File photo;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('photo_test');
    photo = File('${tmp.path}/me.png')..writeAsBytesSync([1, 2, 3, 4]);
  });

  tearDown(() => tmp.delete(recursive: true));

  test(
    'upload sends Firebase token, anon key, content type and bytes',
    () async {
      late http.Request sent;
      final service = SupabaseService(
        idTokenProvider: () async => 'firebase-token',
        functionUrl: 'https://x.supabase.co/functions/v1/profile-photo',
        anonKey: 'anon',
        client: MockClient((req) async {
          sent = req;
          return http.Response(jsonEncode({'url': 'https://x/u.png'}), 200);
        }),
      );

      final url = await service.uploadProfileImage(
        uid: 'u1',
        filePath: photo.path,
      );

      expect(url, 'https://x/u.png');
      expect(sent.method, 'POST');
      expect(sent.headers['Authorization'], 'Bearer firebase-token');
      expect(sent.headers['apikey'], 'anon');
      expect(sent.headers['Content-Type'], startsWith('image/png'));
      expect(sent.bodyBytes, [1, 2, 3, 4]);
    },
  );

  test('upload fails clearly when signed out or server rejects', () async {
    final signedOut = SupabaseService(
      idTokenProvider: () async => null,
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    expect(
      () => signedOut.uploadProfileImage(uid: 'u1', filePath: photo.path),
      throwsException,
    );

    final rejected = SupabaseService(
      idTokenProvider: () async => 't',
      client: MockClient(
        (_) async => http.Response('{"error":"unauthorized"}', 401),
      ),
    );
    expect(
      () => rejected.uploadProfileImage(uid: 'u1', filePath: photo.path),
      throwsException,
    );
  });

  test('deleteAllUserImages sends DELETE and never throws', () async {
    String? method;
    final service = SupabaseService(
      idTokenProvider: () async => 't',
      client: MockClient((req) async {
        method = req.method;
        return http.Response('{"deleted":2}', 200);
      }),
    );
    await service.deleteAllUserImages('u1');
    expect(method, 'DELETE');

    final failing = SupabaseService(
      idTokenProvider: () async => 't',
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    await failing.deleteAllUserImages('u1'); // must not throw
  });
}
