import 'package:paperfold_list/paperfold_list.dart';

class PaperfoldListItemInfo {
  int index;
  int itemCount;
  double unfold;
  bool foldsIn;
  PaperfoldListAxis axis;

  PaperfoldListItemInfo({
    required this.index,
    required this.itemCount,
    required this.unfold,
    required this.foldsIn,
    required this.axis,
  });
}
