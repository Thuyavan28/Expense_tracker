// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String?,
      type: fields[1] as String,
      amount: fields[2] as double,
      currency: fields[3] as String,
      category: fields[4] as String,
      subCategory: fields[5] as String?,
      paymentMethod: fields[6] as String,
      date: fields[7] as DateTime,
      description: fields[8] as String,
      merchantName: fields[9] as String?,
      notes: fields[10] as String?,
      tags: (fields[11] as List?)?.cast<String>(),
      receiptImagePath: fields[12] as String?,
      status: fields[13] as String,
      sourceAccountId: fields[14] as String?,
      destinationAccountId: fields[15] as String?,
      isDuplicate: fields[16] as bool,
      createdAt: fields[17] as DateTime?,
      updatedAt: fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.subCategory)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.merchantName)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.receiptImagePath)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.sourceAccountId)
      ..writeByte(15)
      ..write(obj.destinationAccountId)
      ..writeByte(16)
      ..write(obj.isDuplicate)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
