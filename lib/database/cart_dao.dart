import 'package:floor/floor.dart';

import 'cart_model.dart';

@dao
abstract class MyCartDao {
  @Query('SELECT * FROM CartItems')
  Future<List<CartModel>> getItems();

  @insert
  Future<void> insertItem(CartModel cartModel);

  @Query('DELETE FROM CartItems')
  Future<void> deleteAllItems(); // query without returning an entity

  @delete
  Future<void> deleteOneItem(
      CartModel cartModel); // query without returning an entity

}
