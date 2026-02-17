import 'ant_constants.dart';

/// A single ANT+ message.
///
/// Wire format: `[SYNC(0xA4)] [LENGTH] [MSG_ID] [DATA...] [CHECKSUM]`
/// Checksum = XOR of all bytes from SYNC through DATA.
class AntMessage {
  const AntMessage({required this.messageId, required this.data});

  final int messageId;
  final List<int> data;

  /// Serializes to wire-format bytes for USB bulk write.
  List<int> toBytes() {
    final bytes = <int>[
      AntConstants.syncByte,
      data.length,
      messageId,
      ...data,
    ];
    int checksum = 0;
    for (final b in bytes) {
      checksum ^= b;
    }
    bytes.add(checksum);
    return bytes;
  }

  /// Parses a single ANT+ message from [buffer] starting at [offset].
  ///
  /// Returns `null` if the buffer is incomplete or the checksum is invalid.
  static AntMessage? parse(List<int> buffer, [int offset = 0]) {
    if (offset + 3 > buffer.length) return null;
    if (buffer[offset] != AntConstants.syncByte) return null;

    final dataLength = buffer[offset + 1];
    final totalLength = 4 + dataLength; // sync + len + msgId + data + checksum

    if (offset + totalLength > buffer.length) return null;

    // XOR of all bytes including checksum should equal 0
    int checksum = 0;
    for (int i = offset; i < offset + totalLength; i++) {
      checksum ^= buffer[i];
    }
    if (checksum != 0) return null;

    return AntMessage(
      messageId: buffer[offset + 2],
      data: buffer.sublist(offset + 3, offset + 3 + dataLength),
    );
  }

  /// Extracts all valid messages from a raw USB read buffer.
  static List<AntMessage> parseAll(List<int> buffer) {
    final messages = <AntMessage>[];
    int offset = 0;
    while (offset < buffer.length) {
      // Find next sync byte
      while (offset < buffer.length && buffer[offset] != AntConstants.syncByte) {
        offset++;
      }
      if (offset >= buffer.length) break;
      final msg = parse(buffer, offset);
      if (msg == null) {
        offset++; // skip bad sync and try again
        continue;
      }
      messages.add(msg);
      offset += 4 + msg.data.length;
    }
    return messages;
  }

  @override
  String toString() =>
      'AntMessage(0x${messageId.toRadixString(16)}, data=$data)';
}
