import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/models/recommendation_models.dart';
import 'package:rassoi/recommendation_screen/recommendation_state.dart';
import 'package:transparent_image/transparent_image.dart';

class RecommendationPage extends StatelessWidget {
   RecommendationPage({Key? key}) : super(key: key);
  Map<int, Color> color =
  {
    50:Color.fromRGBO(136,14,79, .1),
    100:Color.fromRGBO(136,14,79, .2),
    200:Color.fromRGBO(136,14,79, .3),
    300:Color.fromRGBO(136,14,79, .4),
    400:Color.fromRGBO(136,14,79, .5),
    500:Color.fromRGBO(136,14,79, .6),
    600:Color.fromRGBO(136,14,79, .7),
    700:Color.fromRGBO(136,14,79, .8),
    800:Color.fromRGBO(136,14,79, .9),
    900:Color.fromRGBO(136,14,79, 1),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFE9D2, color), primaryColor: const Color(0xffFFE9D2)),
      title: "Recommendation Page",
      home: const RecommendationWidget("Recommendations"),
    );
  }
}

class RecommendationWidget extends StatefulWidget {
  final String title;

  const RecommendationWidget(this.title, {Key? key}) : super(key: key);

  @override
  State<RecommendationWidget> createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget> {
  final SuggestionsBoxController suggestionsBoxController = SuggestionsBoxController();
  final searchBoxTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var recoState = Provider.of<RecommendationState>(context);
    return Scaffold(
        appBar: AppBar(
            title:
                Text(widget.title, style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xffFF8816),
            elevation: 0),
        body: GestureDetector(
          onTap: () {
            if (suggestionsBoxController.isOpened()) {
              suggestionsBoxController.close();
            }
          },
          child: Column(
            children: [
              // SearchBar
              getSearchbarWidget(recoState),
              getList(recoState),
            ],
          ),
        ));
  }

  getSearchbarWidget(RecommendationState recoState) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 40,
      child: Material(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TypeAheadField(
            suggestionsBoxController: suggestionsBoxController,
            noItemsFoundBuilder: (context) {
              return getSearchRecommendationWidget("No results found");
            },
            textFieldConfiguration: TextFieldConfiguration(
                controller: searchBoxTextController,
                maxLines: 1,
                style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Color(0xffFF8816)),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
/*                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),*/
                    hintStyle: TextStyle(color: Colors.black26),
                    hintText: "Search any dish",),
            ),
            suggestionsCallback: (pattern) async {
              return recoState.getSuggestions(pattern);
            },
            itemBuilder: (context, data) {
              return getSearchRecommendationWidget(data as String);
            },
            onSuggestionSelected: (suggestion) {
              recoState.currentSearchedQuery = (suggestion as String?);
              if (suggestion != "Search all dishes") {
                searchBoxTextController.text = suggestion!;
              }
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  getList(RecommendationState recoState) {
    List<RecommendationModel> allResults = recoState.getAllResults();
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: allResults.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: 10,
            width: 10,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          if (allResults.elementAt(index).isFavourite) {
            // Favourites
            return getFavouritesWidget(recoState);
          }
          // All Result widget for index
          return getAllResultWidgetForIndex(recoState, allResults.elementAt(index), index);
        },
      ),
    );
  }

  getFavouritesWidget(RecommendationState recoState) {
    List<RecommendationModel> favouritesModels = recoState.getFavourites();
    return favouritesModels.isNotEmpty
        ? SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                    padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
                    child: Text("Favourites",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xffFF8816), decoration: null, decorationStyle: null))),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: favouritesModels.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 10,
                        width: 10,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return getFavouritesWidgetByIndex(
                          favouritesModels.elementAt(index), index);
                    },
                  ),
                )
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget getFavouritesWidgetByIndex(RecommendationModel favouriteRecoModel, int index) {
    String image = favouriteRecoModel.getDishImageUrl();
    return Container(
      color: Colors.black12,
      height: 100,
      child: FadeInImage.memoryNetwork(
        width: 100,
        height: 100,
        placeholder: kTransparentImage,
        fit: BoxFit.cover,
        image: image,
      ),
    );
  }

  getAllResultWidgetForIndex(RecommendationState recoState, RecommendationModel resultModel, int index) {
    String image = resultModel.getDishImageUrl();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resultModel.isStartOfAllResults)
          const Padding(
              padding: EdgeInsets.fromLTRB(10, 15, 10, 25),
              child: Text(
                  "Results",
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xffFF8816)))),
        Container(
          color: Colors.black12,
          height: 200,
          child: getResultImageWidget(context, image, recoState, resultModel),
        )
      ],
    );
  }

  getResultImageWidget(BuildContext context, String image,
      RecommendationState recoState, RecommendationModel dishModel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FadeInImage.memoryNetwork(
          height: 200,
          width: 0,
          placeholder: kTransparentImage,
          fit: BoxFit.cover,
          image: image,
        ),
       getFavouritesIconWidget(dishModel)
      ],
    );
  }

  getFavouritesIconWidget(RecommendationModel dishModel) {
    return  Align(
      alignment: Alignment.topRight,
      child: Container(
        height: 20,
        width: 20,
        margin: EdgeInsets.all(10),
        decoration: ShapeDecoration(shape: CircleBorder()),
        child: Material(
          color: Color(0xfff0af2e),
          shape: CircleBorder(),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(dishModel.isFavourite ? Icons.remove : Icons.add),
            iconSize: 20,
            splashColor:  Colors.pink,
            focusColor: Colors.pink,
            onPressed: () {
/*              dishModel.isFavourite = !dishModel.isFavourite;
                  setState(() {});
                  recoState
                      .toggleFavouriteForDish(dishModel)
                      .then((success) {
                    if (!success) {
                      dishModel.isFavourite = !dishModel.isFavourite;
                      setState(() {});
                      // Show message something went wrong
                    }
                  });*/
            },
          ),
        ),
      ),
    );
  }

  getSearchRecommendationWidget(String suggestionText) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xfffff8e1),
//                  border: Border.all(color: Colors.black26, width: 1),
      ),
      child: ListTile(
        title: Text(
          suggestionText,
          style: const TextStyle(color: Color(0xffFF8816)),
        ),
      ),
    );
  }

  getImageWithFavouriteIcon() {

  }
}
