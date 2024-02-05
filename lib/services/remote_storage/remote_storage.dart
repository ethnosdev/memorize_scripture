// import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteStorage {
  bool _isInitialized = false;

  // late final Supabase _supabase;

  Future<void> init() async {
    // _supabase = await Supabase.initialize(
    //   url: 'https://ztcgzhbwvijzzljcvzal.supabase.co',
    //   anonKey:
    //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0Y2d6aGJ3dmlqenpsamN2emFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTk4NjQzNDgsImV4cCI6MjAxNTQ0MDM0OH0.XZ43wxrv0ukbdCWzhR51E9u5NRzyPH_ofGN0fMVHNSk',
    // );
    _isInitialized = true;
  }

  Future<void> createAccount({
    required String email,
    required String passphrase,
  }) async {
    // final res = await _supabase.client.auth.signUp(
    //   email: email,
    //   password: passphrase,
    // );
  }
}
