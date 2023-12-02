import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

enum SelectionType {
  adminType,
}

final ListProvider =
    StateNotifierProvider<ListNotifier, dynamic>((ref) => ListNotifier(ref));

class ListNotifier extends StateNotifier<dynamic> {
  Ref ref;

  List<Tuple2<String?, String?>?>? getData;
  SelectionType? getSelectionType;
  TextEditingController? txtAdminType = TextEditingController();
  FocusNode focusAdminType = FocusNode();

  ListNotifier(this.ref) : super("");
}

var adminTypeProvider =
    StateProvider<Tuple2<String?, String?>>((ref) => Tuple2("", ""));
