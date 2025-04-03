part of '../../wallet.dart';

/// For operations that are reading data from the blockchain without making a
/// transaction that would modify it, the Ethereum client can read that data
/// from previous states of the blockchain as well. This class specifies which
/// state to use.
class BlockNumber {
  /// Use the state of the blockchain at the block specified.
  const BlockNumber.exact(this.blockNum) : useAbsolute = true;

  /// Use the state of the blockchain with the first block
  const BlockNumber.genesis()
      : useAbsolute = false,
        blockNum = 0;

  /// Use the state of the blockchain as of the latest mined block.
  const BlockNumber.current()
      : useAbsolute = false,
        blockNum = 1;

  /// Use the current state of the blockchain, including pending transactions
  /// that have not yet been mined.
  const BlockNumber.pending()
      : useAbsolute = false,
        blockNum = 2;

  final bool useAbsolute;
  final int blockNum;

  bool get isPending => !useAbsolute && blockNum == 2;

  /// Generates the block parameter as it is accepted by the Ethereum client.
  String toBlockParam() {
    if (useAbsolute) return '0x${blockNum.toRadixString(16)}';

    switch (blockNum) {
      case 0:
        return 'earliest';
      case 1:
        return 'latest';
      case 2:
        return 'pending';
      default:
        return 'latest'; //Can't happen, though
    }
  }

  @override
  String toString() {
    if (useAbsolute) return blockNum.toString();

    return toBlockParam();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockNumber &&
          runtimeType == other.runtimeType &&
          useAbsolute == other.useAbsolute &&
          blockNum == other.blockNum;

  @override
  int get hashCode => useAbsolute.hashCode ^ blockNum.hashCode;
}
