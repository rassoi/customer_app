
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationModel {

  final DocumentSnapshot? _documentSnapshot;

  bool isSearchBar;
  get gatIsSearchBar => isSearchBar;

  bool isStartOfAllResults;

  DocumentSnapshot? get documentSnapshot => _documentSnapshot;

  bool _isFavourites;
  bool get isFavourite => _isFavourites;
  set isFavourite(bool isFavourite) {
    _isFavourites = isFavourite;
  }

  RecommendationModel(this._documentSnapshot, this._isFavourites, {this.isSearchBar = false, this.isStartOfAllResults = false});

  String getDishImageUrl() {
    return _documentSnapshot?.get("image") as String;
  }

  String getDishName() {
    return _documentSnapshot?.get("name") as String;
  }
}