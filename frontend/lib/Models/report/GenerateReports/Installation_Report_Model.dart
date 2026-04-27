import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PostInstallationReport {
  final int reportNumber;
  final String customer;
  final String productCategory;
  final String manufacturer;
  final String slNumber;
  final DateTime soldDate;
  final DateTime warranty;
  final String status;
  final String actionTaken;
  final String noteByEngineer;
  final String clientName;
  final List<String> trainedFor;
  final String signedBy;
  final dynamic clientSignature; // File on mobile, Uint8List on web
  final dynamic pdf; // File on mobile, Uint8List on web

  PostInstallationReport({
    required this.reportNumber,
    required this.customer,
    required this.productCategory,
    required this.manufacturer,
    required this.slNumber,
    required this.soldDate,
    required this.warranty,
    required this.status,
    required this.actionTaken,
    required this.noteByEngineer,
    required this.clientName,
    required this.trainedFor,
    required this.signedBy,
    this.clientSignature,
    this.pdf,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportNumber': reportNumber,
      'customer': customer,
      'productCategory': productCategory,
      'manufacturer': manufacturer,
      'slNumber': slNumber,
      'soldDate': soldDate.toIso8601String(),
      'warranty': warranty.toIso8601String(),
      'status': status,
      'actionTaken': actionTaken,
      'noteByEngineer': noteByEngineer,
      'clientName': clientName,
      'trainedFor': trainedFor,
      'signedBy': signedBy,
    };
  }

  // To send multipart form-data with image and PDF
  Future<Map<String, dynamic>> toMultipartMap() async {
    final Map<String, dynamic> data = toJson();

    if (clientSignature != null) {
      if (kIsWeb) {
        data['clientSignature'] = MultipartFile.fromBytes(
          clientSignature as Uint8List,
          filename: 'signature.jpg',
        );
      } else {
        // We use a dynamic approach to avoid direct dart:io dependency in web builds
        // but for mobile it will be a File object.
        data['clientSignature'] = await MultipartFile.fromFile(
          clientSignature.path,
          filename: 'signature.jpg',
        );
      }
    }
    if (pdf != null) {
      if (kIsWeb) {
        data['pdf'] = MultipartFile.fromBytes(
          pdf as Uint8List,
          filename: 'report.pdf',
        );
      } else {
        data['pdf'] = await MultipartFile.fromFile(
          pdf.path,
          filename: 'report.pdf',
        );
      }
    }

    return data;
  }
}

class FetchInstallationReport {
  final String id;
  final int reportNumber;
  final Customer customer;
  final ProductCategory productCategory;
  final Manufacturer manufacturer;
  final String slNumber;
  final DateTime soldDate;
  final DateTime warranty;
  final String status;
  final String actionTaken;
  final String noteByEngineer;
  final Engineer engineer;
  final Client clientName;
  final List<Client> trainedFor;
  final String? clientSignature;
  final Client signedBy;
  final String? pdf;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  // new fields to match your generator
  final String hospitalName;
  final String hospitalAddress;
  final String hospitalPhone;
  final String hospitalCity;
  final String hospitalState;
  final String serialNumber;
  final String machineStatus;
  final String remarks;
  final String engineerName;
  final DateTime? warrantyStartDate;
  final DateTime? warrantyEndDate;
  final String warrantyDuration;
  final List<String> trainedEmployees;
  final String complaintFrom;

  FetchInstallationReport({
    required this.id,
    required this.reportNumber,
    required this.customer,
    required this.productCategory,
    required this.manufacturer,
    required this.slNumber,
    required this.soldDate,
    required this.warranty,
    required this.status,
    required this.actionTaken,
    required this.noteByEngineer,
    required this.engineer,
    required this.clientName,
    required this.trainedFor,
    required this.clientSignature,
    required this.signedBy,
    required this.pdf,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.hospitalPhone,
    required this.hospitalCity,
    required this.hospitalState,
    required this.serialNumber,
    required this.machineStatus,
    required this.remarks,
    required this.engineerName,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.warrantyDuration,
    required this.trainedEmployees,
    required this.complaintFrom,
  });

  factory FetchInstallationReport.fromJson(Map<String, dynamic> json) {
    try {
      print(
        "🔍 Parsing installation report for reportNumber: ${json['reportNumber']}",
      );

      return FetchInstallationReport(
        id:
            (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))
                ?.toString() ??
            '',
        reportNumber: json['reportNumber'] ?? 0,
        customer: Customer.fromJson(json['customer']),
        productCategory: ProductCategory.fromJson(json['productCategory']),
        manufacturer: Manufacturer.fromJson(json['manufacturer']),
        slNumber: json['slNumber'] ?? '',
        soldDate: DateTime.parse(json['soldDate']),
        warranty: DateTime.parse(json['warranty']),
        status: json['status'] ?? '',
        actionTaken: json['actionTaken'] ?? '',
        noteByEngineer: json['noteByEngineer'] ?? '',
        engineer: Engineer.fromJson(json['engineer']),
        clientName: Client.fromJson(json['clientName']),
        trainedFor:
            (json['trainedFor'] as List)
                .map((e) => Client.fromJson(e))
                .toList(),
        clientSignature: json['clientSignature'],
        signedBy: Client.fromJson(json['signedBy']),
        pdf: json['pdf'],
        date: DateTime.parse(json['date']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        hospitalName: json['hospitalName'] ?? '',
        hospitalAddress: json['hospitalAddress'] ?? '',
        hospitalPhone: json['hospitalPhone'] ?? '',
        hospitalCity: json['hospitalCity'] ?? '',
        hospitalState: json['hospitalState'] ?? '',
        serialNumber: json['serialNumber'] ?? '',
        machineStatus: json['machineStatus'] ?? '',
        remarks: json['remarks'] ?? '',
        engineerName: json['engineerName'] ?? '',
        warrantyStartDate:
            json['warrantyStartDate'] != null
                ? DateTime.parse(json['warrantyStartDate'])
                : null,
        warrantyEndDate:
            json['warrantyEndDate'] != null
                ? DateTime.parse(json['warrantyEndDate'])
                : null,
        warrantyDuration: json['warrantyDuration'] ?? '',
        trainedEmployees: List<String>.from(json['trainedEmployees'] ?? []),
        complaintFrom: json['complaintFrom'] ?? '',
      );
    } catch (e, stackTrace) {
      print("🔥 Error while parsing FetchInstallationReport: $e");
      print(stackTrace);
      rethrow;
    }
  }
}

class Customer {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerPhone2;
  final String customerQuniqueNumber;
  final String addressOne;
  final String addressTwo;
  final String city;
  final String state;
  final String pincode;
  final String customerEmail;
  final String customerGSTIN;

  Customer({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerPhone2,
    required this.customerQuniqueNumber,
    required this.addressOne,
    required this.addressTwo,
    required this.city,
    required this.state,
    required this.pincode,
    required this.customerEmail,
    required this.customerGSTIN,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id:
          (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))
              ?.toString() ??
          '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerPhone2: json['customerPhone2'] ?? '',
      customerQuniqueNumber: json['customerQuniqueNumber'] ?? '',
      addressOne: json['addressOne'] ?? '',
      addressTwo: json['addressTwo'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerGSTIN: json['customerGSTIN'] ?? '',
    );
  }
}

class ProductCategory {
  final String id;
  final String productCategory;
  final String image;

  ProductCategory({
    required this.id,
    required this.productCategory,
    required this.image,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      productCategory: json['productCategory'],
      image: json['image'],
    );
  }
}

class Manufacturer {
  final String id;
  final String manufacturer;

  Manufacturer({required this.id, required this.manufacturer});

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      manufacturer: json['manufacturer'],
    );
  }
}

class Engineer {
  final String id;
  final String name;
  final String phone;
  final String email;

  Engineer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class Client {
  final String id;
  final String name;
  final String phone;
  final DateTime dob;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.dob,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      name: json['name'],
      phone: json['phone'],
      dob: DateTime.tryParse(json['dob'] ?? '') ?? DateTime(1970, 1, 1),
    );
  }
}
