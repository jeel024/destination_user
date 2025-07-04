import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/RoomModel.dart';
import '../models/hotelModel.dart';
import '../utils/Common.dart';
import '../utils/Extensions/shared_pref.dart';
import '../main.dart';
import '../models/DashboardResponse.dart';
import '../models/PlaceModel.dart';
import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';
import 'BaseService.dart';

class RoomService extends BaseService {
  RoomService() {
    ref = db.collection('rooms');
  }

  Future<HotelModel> userByEmail(String? email) async {
    return await ref!.where(UserKeys.email, isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return HotelModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw language.noUserFound;
      }
    });
  }

  Future<List<PlaceModel>> fetchPlaceList({required List<PlaceModel> list, String? catId, String? stateId, bool isPopular = false}) async {
    Query query;
    QuerySnapshot querySnapshot;

    if (catId != null) {
      query = ref!.where(CommonKeys.status, isEqualTo: 1).where(PlaceKeys.categoryId, isEqualTo: catId).orderBy(CommonKeys.createdAt, descending: true);
    } else if (stateId != null) {
      query = ref!.where(CommonKeys.status, isEqualTo: 1).where(PlaceKeys.stateId, isEqualTo: stateId).orderBy(CommonKeys.createdAt, descending: true);
    } else if (isPopular) {
      query = ref!.where(CommonKeys.status, isEqualTo: 1).orderBy(PlaceKeys.rating, descending: true);
    } else {
      query = ref!.where(CommonKeys.status, isEqualTo: 1).orderBy(CommonKeys.createdAt, descending: true);
    }

    if (list.isEmpty) {
      querySnapshot = await query.limit(perPageLimit).get();
    } else {
      querySnapshot = await query.startAfterDocument(await ref!.doc(list[list.length - 1].id).get()).limit(perPageLimit).get();
    }
    List<PlaceModel> data = querySnapshot.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList();

    return data;
  }

  Future<List<RoomModel>> getRoomsByHotelId({required String id}) async {
    print(id);

    Query query = ref!.where(PlaceKeys.hotelId, isEqualTo: id).orderBy(CommonKeys.updatedAt, descending: true);

    return await query.get().then((x) {
      return x.docs.map((y) => RoomModel.fromJson(y.data() as Map<String, dynamic>)).toList();
    });

  }





}
