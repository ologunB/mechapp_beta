import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechapp/each_product.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'main_cart.dart';

class ShopContainer extends StatefulWidget {
  String from;

  ShopContainer(this.from);

  @override
  _ShopContainerState createState() => _ShopContainerState();
}

TextEditingController searchShopController = TextEditingController();
bool productVisible = true;
bool searchVisible = false;
bool noItemFound = false;

List<ShopItem> toolList = List();
List<ShopItem> partList = List();
List<ShopItem> allProducts = List();
List<ShopItem> sortedProducts = List();

void onSearchProduct(String val, BuildContext context, setState) {
  if (allProducts != null) {
    val = val.trim();
    if (val.isNotEmpty) {
      sortedProducts.clear();
      for (ShopItem item in allProducts) {
        if (item.name.toUpperCase().contains(val.toUpperCase())) {
          sortedProducts.add(item);
        }
      }
      if (sortedProducts.isEmpty) {
        setState(() {
          productVisible = false;
          searchVisible = true;
          noItemFound = true;
        });
        return;
      }
      setState(() {
        noItemFound = false;

        productVisible = false;
        searchVisible = true;
      });
    } else {
      setState(() {
        noItemFound = false;

        productVisible = true;
        searchVisible = false;
        FocusScope.of(context).unfocus();
      });
    }
  } else {
    showCenterToast("Getting items", context);
  }
}

class _ShopContainerState extends State<ShopContainer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool isSearchingShop = false;

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: widget.from == "cart" ? Colors.white : primaryColor),
          backgroundColor: primaryColor,
          elevation: 0.0,
          title: isSearchingShop
              ? CupertinoTextField(
                  placeholder: "Search...",
                  placeholderStyle: TextStyle(fontWeight: FontWeight.w400),
                  padding: EdgeInsets.all(10),
                  controller: searchShopController,
                  onChanged: (val) {
                    onSearchProduct(val, context, setState);
                  },
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )
              : TabBar(
                  isScrollable: true,
                  unselectedLabelColor: Colors.white70,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.blue),
                  tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Tools",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Parts",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: isSearchingShop
                    ? Icon(Icons.close, color: Colors.white)
                    : Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  isSearchingShop = !isSearchingShop;
                  searchShopController.clear();

                  if (isSearchingShop) {
                    noItemFound = false;
                    productVisible = false;
                    searchVisible = true;
                    FocusScope.of(context).requestFocus();
                  } else {
                    noItemFound = false;
                    productVisible = true;
                    searchVisible = false;
                    FocusScope.of(context).unfocus();
                  }
                  setState(() {});
                }),
          ],
        ),
        floatingActionButton: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              color: primaryColor, borderRadius: BorderRadius.circular(30.0)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return MainCart(main: 'product');
                  },
                ),
              );
            },
            child: Icon(
              Icons.shopping_cart,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              Visibility(
                  child:
                      TabBarView(children: [ShopToolsFrag(), ShopPartsFrag()]),
                  visible: productVisible),
              Visibility(
                child: listBuilder(sortedProducts, context),
                visible: searchVisible,
              ),
              Visibility(
                child: emptyList("Shop Item"),
                visible: noItemFound,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ShopToolsFrag extends StatefulWidget {
  @override
  _ShopToolsFragState createState() => _ShopToolsFragState();
}

class _ShopToolsFragState extends State<ShopToolsFrag>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final container = _buildFutureBuilder(toolList);

    return Container(
      height: double.infinity,
      color: Color(0xb090A1AE),
      child: container,
    );
  }
}

class ShopPartsFrag extends StatefulWidget {
  @override
  _ShopPartsFragState createState() => _ShopPartsFragState();
}

class _ShopPartsFragState extends State<ShopPartsFrag>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final container = _buildFutureBuilder(partList);

    return Container(
      height: double.infinity,
      color: Color(0xb090A1AE),
      child: container,
    );
  }
}

Future<List<ShopItem>> _getItems() async {
  DatabaseReference dataRef =
      FirebaseDatabase.instance.reference().child("Shop Collection");

  await dataRef.once().then((snapshot) {
    var kEYS = snapshot.value.keys;
    Map dATA = snapshot.value;

    toolList.clear();
    partList.clear();
    allProducts.clear();
    for (var index in kEYS) {
      for (var index2 in dATA[index].keys) {
        String tempName = dATA[index][index2]['shop_item_name'];
        String tempPrice = dATA[index][index2]['shop_item_price'].toString();
        String tempSeller = dATA[index][index2]['shop_item_seller'];
        String tempEmail = dATA[index][index2]['shop_item_email'];
        String tempNumber = dATA[index][index2]['shop_item_phoneNo'];
        String tempDescript = dATA[index][index2]['shop_item_descrpt'];
        List tempImage = dATA[index][index2]['shop_item_images'];
        String tempID = dATA[index][index2]['shop_item_ID'];
        String tempType = dATA[index][index2]['shop_item_type'];

        ShopItem tempItem = ShopItem(
            name: tempName,
            price: tempPrice,
            soldBy: tempSeller,
            images: tempImage,
            desc: tempDescript,
            email: tempEmail,
            number: tempNumber,
            itemID: tempID);
        if (tempType == "Tool") {
          toolList.add(tempItem);
        } else {
          partList.add(tempItem);
        }
        allProducts.add(tempItem);
      }
    }
  });
  return allProducts;
}

Widget _buildFutureBuilder(List<ShopItem> tempList) {
  return Center(
    child: FutureBuilder<List<ShopItem>>(
      future: _getItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return tempList.length == 0
              ? emptyList("Shop Item")
              : listBuilder(tempList, context);
        }
        return CupertinoActivityIndicator(radius: 20);
      },
    ),
  );
}

Widget listBuilder(List<ShopItem> tempList, BuildContext context) {
  return Container(
    color: Color(0xb090A1AE),
    height: MediaQuery.of(context).size.height,
    child:



    StaggeredGridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      // I only need two card horizontally
      children: tempList.map<Widget>((item) {
        //Do you need to go somewhere when you tap on this card, wrap using InkWell and add your route
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => EachProduct(
                  shopItem: item,
                ),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CachedNetworkImage(
                        imageUrl: item.images[0],
                        height: 100,
                        width: 100,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )),
                  Text(item.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: primaryColor)),
                  Text("\₦ " + item.price,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          color: primaryColor,
                          fontWeight: FontWeight.w500)),
                  Text(
                    "Sold By: ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    item.soldBy,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.w900),
                  )
                ],
              ),
            ),
          ),
        );
      }).toList(),
      staggeredTiles: tempList
          .map<StaggeredTile>((_) => StaggeredTile.fit(2))
          .toList(),
      mainAxisSpacing: 3.0,
      crossAxisSpacing: 4.0,
    ),
  );
}
