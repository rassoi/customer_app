import 'package:flutter/material.dart';
import 'package:rassoi/models/recommendation_models.dart';
import 'package:rassoi/recommendation_screen/recommendation_state.dart';
import 'package:transparent_image/transparent_image.dart';

import '../home_screen/main.dart';

class RecommendationImageWidget extends StatefulWidget {
  final String image;
  final RecommendationState recoState;
  final RecommendationModel dishModel;
  final int height;
  final int width;

  const RecommendationImageWidget(
      this.image, this.recoState, this.dishModel, this.height, this.width,
      {Key? key})
      : super(key: key);

  @override
  State<RecommendationImageWidget> createState() =>
      _RecommendationImageWidgetState();
}

class _RecommendationImageWidgetState extends State<RecommendationImageWidget> {
  _RecommendationImageWidgetState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FadeInImage.memoryNetwork(
          height: widget.height.toDouble(),
          width: widget.width.toDouble(),
          placeholder: kTransparentImage,
          fit: BoxFit.cover,
          image: widget.image,
        ),
        getFavouritesIconWidget()
      ],
    );
  }

  getFavouritesIconWidget() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        height: 20,
        width: 20,
        margin: const EdgeInsets.all(10),
        decoration: const ShapeDecoration(shape: CircleBorder()),
        child: Material(
          color: const Color(0xfff0af2e),
          shape: const CircleBorder(),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(widget.dishModel.isFavourite ? Icons.remove : Icons.add),
            iconSize: 20,
            splashColor: Colors.pink,
            focusColor: Colors.pink,
            onPressed: () {
              widget.dishModel.isFavourite = !widget.dishModel.isFavourite;
              setState(() {});
              widget.recoState
                  .toggleFavouriteForDish(widget.dishModel)
                  .then((success) {
                if (!success) {
                  widget.dishModel.isFavourite = !widget.dishModel.isFavourite;
                  setState(() {});
                  // Show message something went wrong
                  showSnackBar(context, "Something went wrong");
                } else {
                  String joiningPhrase = widget.dishModel.isFavourite
                      ? " saved to"
                      : " removed from";
                  showSnackBar(
                      context,
                      widget.dishModel.getDishName() +
                          joiningPhrase +
                          " favourites");
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
