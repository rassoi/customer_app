import 'package:flutter/material.dart';

class FoodCategory extends StatelessWidget {
  final String? categoryName;
  final String? image;
  final bool shouldShowAllButton;

  const FoodCategory(this.categoryName, this.image, this.shouldShowAllButton,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      alignment: Alignment.center,
      child: !shouldShowAllButton && image != null && categoryName != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.network(
                    image!,
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: Text(categoryName!, maxLines: 1)),
              ],
            )
          : const Icon(Icons.add_circle,
          ),
    );
  }
}
