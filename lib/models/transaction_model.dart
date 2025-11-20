import 'package:flutter/material.dart';

enum TransactionType { receita, despesa }

enum TransactionStatus { pendente, pago }

class TransactionModel {
  int? id;
  TransactionType type;
  double value;
  String description;
  DateTime dueDate;
  DateTime? paymentDate;
  String category;
  String account;
  TransactionStatus status;
  String? recurrence;
  String? attachmentPath;

  TransactionModel({
    this.id,
    required this.type,
    required this.value,
    required this.description,
    required this.dueDate,
    this.paymentDate,
    required this.category,
    required this.account,
    required this.status,
    this.recurrence,
    this.attachmentPath,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'] == 'receita' ? TransactionType.receita : TransactionType.despesa,
      value: map['value'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      paymentDate: map['paymentDate'] != null ? DateTime.parse(map['paymentDate']) : null,
      category: map['category'],
      account: map['account'],
      status: map['status'] == 'pago' ? TransactionStatus.pago : TransactionStatus.pendente,
      recurrence: map['recurrence'],
      attachmentPath: map['attachmentPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'value': value,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'category': category,
      'account': account,
      'status': status.name,
      'recurrence': recurrence,
      'attachmentPath': attachmentPath,
    };
  }
}