class Project {
  final String invoiceNo;
  final String status;
  final String customerId;
  final String fullName;
  final String roll;
  final String email;
  final String phone;
  final String projectTitle;
  final String service;
  final String feeAmount;
  final String paymentStatus;
  final String paymentMethod;
  final String transactionId;
  final String paymentDate;

  Project({
    required this.invoiceNo,
    required this.status,
    required this.customerId,
    required this.fullName,
    required this.roll,
    required this.email,
    required this.phone,
    required this.projectTitle,
    required this.service,
    required this.feeAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentDate,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      invoiceNo: (json['Invoice No'] ?? json['invoiceNo'] ?? '').toString(),
      status: (json['Status'] ?? json['status'] ?? '').toString(),
      customerId: (json['Customer ID'] ?? json['customerId'] ?? '').toString(),
      fullName: (json['Full Name'] ?? json['fullName'] ?? '').toString(),
      roll: (json['Roll'] ?? json['roll'] ?? '').toString(),
      email: (json['Email Address'] ?? json['emailAddress'] ?? '').toString(),
      phone: (json['Phone Number'] ?? json['phoneNumber'] ?? '').toString(),
      projectTitle: (json['Project Title'] ?? json['projectTitle'] ?? '').toString(),
      service: (json['Service'] ?? json['service'] ?? '').toString(),
      feeAmount: (json['Fee Amount'] ?? json['feeAmount'] ?? '0').toString(),
      paymentStatus: (json['Payment Status'] ?? json['paymentStatus'] ?? '').toString(),
      paymentMethod: (json['Payment Method'] ?? json['paymentMethod'] ?? '').toString(),
      transactionId: (json['Transcation ID'] ?? json['transactionId'] ?? '').toString(),
      paymentDate: (json['Payment Date'] ?? json['paymentDate'] ?? '').toString(),
    );
  }

  bool get isPaid {
    final s = paymentStatus.toLowerCase();
    return s.contains('paid') && !s.contains('non');
  }

  double get feeDouble {
    if (feeAmount.isEmpty) return 0.0;
    try {
      final clean = feeAmount.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(clean);
    } catch (_) {
      return 0.0;
    }
  }

  bool get isCompleted {
    final s = status.toLowerCase();
    return s.contains('complet') || s.contains('done');
  }

  bool get isPending {
    final s = status.toLowerCase();
    return s.contains('pend') || s.contains('hold');
  }
}