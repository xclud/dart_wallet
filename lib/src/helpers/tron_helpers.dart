part of wallet;

/// Validates the given tron address.
bool isValidTronAddress(String address, [int version = 0x41]) {
  try {
    final decoded = Base58CheckCodec.bitcoin().decode(address);
    return decoded.version == version;
  } catch (e) {
    //
  }

  return false;
}
