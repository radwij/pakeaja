class Rental {
  final String id;
  final String itemId;
  final String renterId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final bool depositPaid;
  final double pricePerDay;
  final double totalPrice;
  final DateTime? returnedAt;

  Rental({
    required this.id,
    required this.itemId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.depositPaid,
    required this.pricePerDay,
    required this.totalPrice,
    this.returnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'renterId': renterId,
      'ownerId': ownerId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'depositPaid': depositPaid,
      'pricePerDay': pricePerDay,
      'totalPrice': totalPrice,
      if (returnedAt != null) 'returnedAt': returnedAt!.toIso8601String(),
    };
  }

  factory Rental.fromMap(String id, Map<String, dynamic> map) {
    return Rental(
      id: id,
      itemId: map['itemId'],
      renterId: map['renterId'],
      ownerId: map['ownerId'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: map['status'],
      depositPaid: map['depositPaid'],
      pricePerDay: (map['pricePerDay'] as num).toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      returnedAt:
          map['returnedAt'] != null ? DateTime.parse(map['returnedAt']) : null,
    );
  }
}
