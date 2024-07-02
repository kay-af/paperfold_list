import 'package:paperfold_list/paperfold_list.dart';

class PaperfoldInfo {
  int index;
  int itemCount;
  double unfold;
  bool foldsIn;
  PaperfoldAxis axis;

  PaperfoldInfo({
    required this.index,
    required this.itemCount,
    required this.unfold,
    required this.foldsIn,
    required this.axis,
  });
}
