import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

class NestedExample extends StatelessWidget {
  const NestedExample();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextFormField(
          key: const Key('firstName'),
          initialValue: 'John',
          decoration: const InputDecoration(labelText: 'First Name'),
        ),
        TextFormField(
          key: const Key('lastName'),
          initialValue: 'Doe',
          decoration: const InputDecoration(labelText: 'Last Name'),
        ),
        TextFormField(
          key: const Key('email'),
          initialValue: 'john.doe@example.com',
          decoration: const InputDecoration(labelText: 'Email'),
          validator: Validator().email(),
        ),
        TextFormField(
          key: const Key('phone'),
          initialValue: '+1 999-999-9999',
          decoration: const InputDecoration(labelText: 'Phone Number'),
          inputFormatters: Formatter().phone(countryCode: 'US'),
        ),
        Form(
          key: const Key('address'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('street'),
                initialValue: '123 Main St',
                decoration: const InputDecoration(labelText: 'Street Address'),
              ),
              TextFormField(
                key: const Key('city'),
                initialValue: 'Springfield',
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextFormField(
                key: const Key('state'),
                initialValue: 'IL',
                decoration: const InputDecoration(labelText: 'State'),
              ),
              TextFormField(
                key: const Key('zip'),
                initialValue: '62704',
                decoration: const InputDecoration(labelText: 'ZIP Code'),
                inputFormatters: Formatter().mask('00000'),
              ),
              Form(
                key: const Key('address'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: const Key('street'),
                      initialValue: '456 Elm St',
                      decoration: const InputDecoration(
                        labelText: 'Secondary Street Address',
                      ),
                    ),
                    TextFormField(
                      key: const Key('city'),
                      initialValue: 'Shelbyville',
                      decoration:
                          const InputDecoration(labelText: 'Secondary City'),
                    ),
                    TextFormField(
                      key: const Key('state'),
                      initialValue: 'IL',
                      decoration:
                          const InputDecoration(labelText: 'Secondary State'),
                    ),
                    TextFormField(
                      key: const Key('zip'),
                      initialValue: '62705',
                      decoration: const InputDecoration(
                        labelText: 'Secondary ZIP Code',
                      ),
                      inputFormatters: Formatter().mask('00000'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Form(
          key: const Key('additionalInfo'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('occupation'),
                initialValue: 'Software Developer',
                decoration: const InputDecoration(labelText: 'Occupation'),
              ),
              TextFormField(
                key: const Key('company'),
                initialValue: 'Tech Solutions Inc.',
                decoration: const InputDecoration(labelText: 'Company'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore_for_file: type=lint
class UserData {
  UserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.additionalInfo,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final Address address;
  final AdditionalInfo additionalInfo;

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address.toMap(),
      'additionalInfo': additionalInfo.toMap(),
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    T cast<T>(String k) => map[k] is T
        ? map[k] as T
        : throw ArgumentError.value(map[k], k, '$T ← ${map[k].runtimeType}');
    return UserData(
      firstName: cast<String>('firstName'),
      lastName: cast<String>('lastName'),
      email: cast<String>('email'),
      phone: cast<String>('phone'),
      address: Address.fromMap(Map.from(cast<Map>('address'))),
      additionalInfo:
          AdditionalInfo.fromMap(Map.from(cast<Map>('additionalInfo'))),
    );
  }
}

class Address {
  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    this.address,
  });

  final String street;
  final String city;
  final String state;
  final String zip;
  final Address? address;

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'address': address?.toMap(),
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    T cast<T>(String k) => map[k] is T
        ? map[k] as T
        : throw ArgumentError.value(map[k], k, '$T ← ${map[k].runtimeType}');
    return Address(
      street: cast<String>('street'),
      city: cast<String>('city'),
      state: cast<String>('state'),
      zip: cast<String>('zip'),
      address: map['address'] == null
          ? null
          : Address.fromMap(Map.from(cast<Map>('address'))),
    );
  }
}

class AdditionalInfo {
  AdditionalInfo({
    required this.occupation,
    required this.company,
  });

  final String occupation;
  final String company;

  Map<String, dynamic> toMap() {
    return {
      'occupation': occupation,
      'company': company,
    };
  }

  factory AdditionalInfo.fromMap(Map<String, dynamic> map) {
    T cast<T>(String k) => map[k] is T
        ? map[k] as T
        : throw ArgumentError.value(map[k], k, '$T ← ${map[k].runtimeType}');
    return AdditionalInfo(
      occupation: cast<String>('occupation'),
      company: cast<String>('company'),
    );
  }
}
