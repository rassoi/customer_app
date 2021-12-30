
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationModel {

  final DocumentSnapshot? _documentSnapshot;

  bool isSearchBar;
  get gatIsSearchBar => isSearchBar;

  DocumentSnapshot? get documentSnapshot => _documentSnapshot;

  final bool _isFavourites;
  bool get isFavourite => _isFavourites;


  RecommendationModel(this._documentSnapshot, this._isFavourites, {this.isSearchBar = false});

  String getDishImageUrl() {
    return _documentSnapshot?.get("img") as String;
  }

  String getDishName() {
    return _documentSnapshot?.get("name") as String;
  }
}