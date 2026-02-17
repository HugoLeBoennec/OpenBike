import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ant/ant_message.dart';

void main() {
  group('AntMessage — toBytes', () {
    test('produces correct wire format with XOR checksum', () {
      final msg = AntMessage(messageId: 0x4A, data: [0x00]);
      final bytes = msg.toBytes();

      // [SYNC=0xA4] [LEN=1] [MSGID=0x4A] [DATA=0x00] [CHECKSUM]
      expect(bytes.length, 5);
      expect(bytes[0], 0xA4); // sync
      expect(bytes[1], 1); // length
      expect(bytes[2], 0x4A); // message ID
      expect(bytes[3], 0x00); // data

      // Checksum: XOR of all preceding bytes
      final expected = 0xA4 ^ 0x01 ^ 0x4A ^ 0x00;
      expect(bytes[4], expected);
    });

    test('multi-byte data produces correct length and checksum', () {
      final msg = AntMessage(
        messageId: 0x46,
        data: [0x00, 0xB9, 0xA5, 0x21, 0xFB, 0xBD, 0x72, 0xC3, 0x45],
      );
      final bytes = msg.toBytes();
      expect(bytes[1], 9); // length = 9 data bytes
      expect(bytes.length, 13); // sync + len + msgId + 9 data + checksum

      // Verify checksum
      int xor = 0;
      for (int i = 0; i < bytes.length; i++) {
        xor ^= bytes[i];
      }
      expect(xor, 0);
    });

    test('empty data produces valid message', () {
      final msg = AntMessage(messageId: 0x6F, data: []);
      final bytes = msg.toBytes();
      expect(bytes.length, 4); // sync + len(0) + msgId + checksum
      expect(bytes[1], 0);
    });
  });

  group('AntMessage — parse', () {
    test('round-trip: parse(toBytes()) recovers original', () {
      final original = AntMessage(messageId: 0x4E, data: [0, 1, 2, 3, 4, 5, 6, 7, 8]);
      final bytes = original.toBytes();
      final parsed = AntMessage.parse(bytes);
      expect(parsed, isNotNull);
      expect(parsed!.messageId, original.messageId);
      expect(parsed.data, original.data);
    });

    test('returns null for empty buffer', () {
      expect(AntMessage.parse([]), isNull);
    });

    test('returns null for truncated buffer', () {
      expect(AntMessage.parse([0xA4, 5, 0x4E]), isNull);
    });

    test('returns null for wrong sync byte', () {
      expect(AntMessage.parse([0x00, 1, 0x4A, 0x00, 0xEE]), isNull);
    });

    test('returns null for bad checksum', () {
      // Valid message with corrupted checksum
      final msg = AntMessage(messageId: 0x4A, data: [0x00]);
      final bytes = msg.toBytes();
      bytes[bytes.length - 1] ^= 0xFF; // corrupt checksum
      expect(AntMessage.parse(bytes), isNull);
    });

    test('parses at non-zero offset', () {
      final msg = AntMessage(messageId: 0x42, data: [0x01, 0x02]);
      final bytes = [0xFF, 0xFF, ...msg.toBytes()]; // garbage prefix
      final parsed = AntMessage.parse(bytes, 2);
      expect(parsed, isNotNull);
      expect(parsed!.messageId, 0x42);
      expect(parsed.data, [0x01, 0x02]);
    });
  });

  group('AntMessage — parseAll', () {
    test('extracts multiple concatenated messages', () {
      final msg1 = AntMessage(messageId: 0x4A, data: [0x00]);
      final msg2 = AntMessage(messageId: 0x4E, data: [0, 1, 2, 3, 4, 5, 6, 7, 8]);
      final buffer = [...msg1.toBytes(), ...msg2.toBytes()];
      final results = AntMessage.parseAll(buffer);
      expect(results.length, 2);
      expect(results[0].messageId, 0x4A);
      expect(results[1].messageId, 0x4E);
    });

    test('skips garbage bytes between messages', () {
      final msg = AntMessage(messageId: 0x40, data: [0x00, 0x46, 0x00]);
      final buffer = [0xFF, 0xFE, ...msg.toBytes()];
      final results = AntMessage.parseAll(buffer);
      expect(results.length, 1);
      expect(results[0].messageId, 0x40);
    });

    test('returns empty list for empty buffer', () {
      expect(AntMessage.parseAll([]), isEmpty);
    });

    test('returns empty list for all-garbage buffer', () {
      expect(AntMessage.parseAll([0x00, 0x01, 0x02, 0x03]), isEmpty);
    });
  });
}
