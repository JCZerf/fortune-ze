enum SlotSymbol { tiger, cherry, seven, coin }

class SlotItem {
  final SlotSymbol symbol;
  const SlotItem(this.symbol);

  String get assetName {
    switch (symbol) {
      case SlotSymbol.tiger:
        return '🐯';
      case SlotSymbol.cherry:
        return '🍒';
      case SlotSymbol.seven:
        return '7';
      case SlotSymbol.coin:
        return '🪙';
    }
  }
}
