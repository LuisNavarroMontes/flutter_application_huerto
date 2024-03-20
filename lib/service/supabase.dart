import 'package:supabase/supabase.dart';

class Supabase {
  static String supabaseUrl = "https://pxafmjqslgpswndqzfvm.supabase.co";
  static String supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4YWZtanFzbGdwc3duZHF6ZnZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTAzNjYzNjIsImV4cCI6MjAyNTk0MjM2Mn0.xbGjWmYqPUO3i2g1_4tmE7sWhI_c9ymFqckSA_CaFOs";

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  Future<void> addData(String table, Map<String, dynamic> object) async {
    final data = await client.from(table).insert(object);

    if (data != null) {
      print('Error al insertar datos: ${data}');
    } else {
      print('Datos insertados con éxito');
    }
  }

  Future<List<dynamic>> readData(String table) async {
    try {
      final data = await client.from(table).select();
      return data as List<dynamic>;
    } catch (e) {
      print('Error al leer datos: $e');
      return [];
    }
  }

  Future<void> updateData(
      String table, int id, Map<String, dynamic> newValues) async {
    final data = await client.from(table).update(newValues).eq('id', id);

    if (data != null) {
      print('Error al actualizar datos: ${data}');
    } else {
      print('Datos actualizados con éxito');
    }
  }

  Future<void> deleteData(String table, int id) async {
    final data = await client.from(table).delete().eq('id', id);

    if (data != null) {
      print('Error al eliminar datos: ${data}');
    } else {
      print('Datos eliminados con éxito');
    }
  }
}