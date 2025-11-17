// lib/models/transaction_model.dart
import 'package:flutter/material.dart';

// Enum para o tipo de transação [cite: 60]
enum TransactionType { receita, despesa }

// Enum para o status da transação [cite: 98]
enum TransactionStatus { pendente, pago }

class TransactionModel {
  int? id;
  TransactionType type; // [cite: 60]
  double value; // [cite: 62]
  String description; // [cite: 65]
  DateTime dueDate; // Data de Vencimento/Previsão [cite: 68]
  DateTime? paymentDate; // Data de Pagamento/Recebimento (opcional) [cite: 73]
  String category; // [cite: 83]
  String account; // [cite: 78]
  TransactionStatus status; // [cite: 98]
  // Campos opcionais [cite: 90, 100]
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

  // Converte um Map (do SQLite) para o modelo
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

  // Converte o modelo para um Map (para o SQLite)
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