import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  List<Company> _companyList = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCompanyData(String query) async {
    try {
      final response = await _dio.get(
        'https://www.alphavantage.co/query',
        queryParameters: {
          'function': 'SYMBOL_SEARCH',
          'keywords': query,
          'apikey': 'WMZ5VGDX2JJVI6ZI',
        },
      );

      final results = response.data['bestMatches'] as List<dynamic>;
      setState(() {
        _companyList = results
            .map((companyData) => Company.fromJson(companyData))
            .toList();
      });
    } catch (error) {
      print('Error fetching company data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _fetchCompanyData(value);
              },
              decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _companyList.length,
              itemBuilder: (context, index) {
                final company = _companyList[index];
                return ListTile(
                  title: Text(company.name),
                  subtitle: Text(company.symbol),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _addToWatchlist(company);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Added to watchlist")));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addToWatchlist(Company company) async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, 'watchlist.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS watchlist (symbol TEXT PRIMARY KEY, name TEXT)',
        );
      },
    );

    await database.insert(
      'watchlist',
      {'symbol': company.symbol, 'name': company.name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await database.close();
  }
}

class Company {
  final String symbol;
  final String name;
    final String price;


  Company({required this.symbol, required this.name,required this.price});

  factory Company.fromJson(Map<String, dynamic> json) {
    print(json);
    return Company(
      symbol: json['1. symbol'],
      name: json['2. name'],
      price:'arro'
    );
  }
}
