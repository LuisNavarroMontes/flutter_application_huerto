import 'package:flutter_application_huerto/models/userLoged.dart';
import 'package:flutter_application_huerto/service/supabaseService.dart';
import 'package:flutter_guid/flutter_guid.dart';

class UserSupabase {
  final client = SupabaseService().client;

  Future<void> updateUser(UserLoged userLoged) async {
    Map<String, dynamic> newValues = {
      "id": userLoged.id.value,
      "name": userLoged.name,
      "email": userLoged.email,
      "community_id":
          userLoged.community_id == null ? null : userLoged.community_id!.value,
      "isAdmin": userLoged.community_id == null ? null : userLoged.is_admin!
    };
    await SupabaseService().updateData("User", userLoged.id.value, newValues);
  }

  Future<void> addUser(UserLoged userLoged) async {
    Map<String, dynamic> newValues = {
      "name": userLoged.name,
      "email": userLoged.email,
      "community_id":
          userLoged.community_id == null ? null : userLoged.community_id!.value,
      "isAdmin": userLoged.is_admin == null ? null : userLoged.is_admin!
    };

    await SupabaseService().addData("User", newValues);
  }

  Future<UserLoged?> getUserById(Guid id) async {
    final data = await SupabaseService().readDataById("User", id.value);
    if (data.length == 0) {
      return null;
    } else {
      if (data[0]["community_id"] == null) {
        final user = UserLoged(
          id: Guid(data[0]
              ['id']), // Asegúrate de convertir el ID a Guid si es necesario
          name: data[0]['name'],
          email: data[0]['email'],
          community_id:
              null, // Asegúrate de que 'community_id' es opcional y maneja el caso en que no esté presente
          is_admin: data[0]['isAdmin'],
        );
        return user;
      } else {
        final user = UserLoged(
          id: Guid(data[0]
              ['id']), // Asegúrate de convertir el ID a Guid si es necesario
          name: data[0]['name'],
          email: data[0]['email'],
          community_id: Guid(data[0][
              'community_id']), // Asegúrate de que 'community_id' es opcional y maneja el caso en que no esté presente
          is_admin: data[0]['isAdmin'],
        );
        return user;
      }
    }
  }
}
